class MyrakesController < ApplicationController
  autocomplete :myrake, :name, :full => true

  def index
    redirect_to master_rakes_path
  end

  def show
    if !user_signed_in?
      redirect_to master_rakes_path
      return
    end
    session[:rake_class] = Myrake
    @rake = Myrake.find(params[:id])
    @top_rakes_count = Myrake.where("user_id = ? AND top_rake = 1", @rake.user_id).count
    parent_rakes = Leaflet.where("leaflet_type_id = 15 AND url ILIKE ?", "%master_rakes/" + @rake.master_rake.slug).pluck(:author).map(&:to_i)
    @parent_master_rakes = MasterRake.where("id IN (?)", parent_rakes)
    @children_master_rakes = MasterRake.where("slug IN (?)",
                                Leaflet.where("leaflet_type_id = 15 AND author IN (?)",
                                        @rake.master_rake_id.to_s).pluck(:url).map{|x| x.partition("master_rakes/").last })
    @sibling_master_rakes = MasterRake.where("id <> ? AND slug IN (?)",
                               @rake.master_rake_id,
                               Leaflet.where("leaflet_type_id = 15 AND author IN (?)", 
                                       @parent_master_rakes.pluck(:id).map(&:to_s)).pluck(:url).map{|x| x.partition("master_rakes/").last })
    @children_master_rakes -= @sibling_master_rakes
    @sibling_master_rakes -= @parent_master_rakes
    if params[:view].nil? || params[:view] == "tasks"
      if @rake.user_id != current_user.id
        redirect_to user_path(current_user)
        return
      end
      @overdue_leaflets = HeapLeafletMap.includes(:heap).where("heap_id IN (?) AND reminder_at < ?",
                                               @rake.heaps.pluck(:id).flatten,
                                               Time.now).order(:reminder_at)
      @scheduled_leaflets = HeapLeafletMap.includes(:heap).where("heap_id IN (?) AND reminder_at > ?",
                                                 @rake.heaps.pluck(:id).flatten,
                                                 Time.now).order(:reminder_at)
      myrake_ids = @rake.master_rake.myrakes.pluck(:id)
      heap_ids = Heap.where("myrake_id IN (?)", myrake_ids).pluck(:id)
      @copy_leaflets = HeapLeafletMap.where("reminder_at IS NOT NULL AND heap_id IN (?) AND leaflet_id NOT IN (?)",
                                            heap_ids,
                                            @scheduled_leaflets.pluck(:leaflet_id).flatten).order(:reminder_at).limit(20)
      @heap_leaflets = @overdue_leaflets + @scheduled_leaflets
      if params[:origin] == "due"
        @due_active = "active"
        @scheduled_active = ""
        @copy_active = ""
      elsif params[:origin] == "scheduled"
        @due_active = ""
        @scheduled_active = "active"
        @copy_active = ""
      elsif params[:origin] == "copy"
        @due_active = ""
        @scheduled_active = ""
        @copy_active = "active"
      else
        @due_active = "active"
        @scheduled_active = ""
        @copy_active = ""
      end
    elsif params[:view] == "news"
      if user_signed_in? && current_user.admin?
        @heaps = @rake.heaps
      else
        @heaps = @rake.heaps.where.not(leaflet_type_id: 15)
      end
      @heap_ids = @heaps.pluck(:id)
      @leaflet_ids = HeapLeafletMap.where("heap_id IN (?)", @heap_ids).pluck(:leaflet_id)
      @heap_leaflets = Leaflet.where("id IN (?)", @leaflet_ids)
      # -- This part has to be more refined because it creates duplicates...
      if user_signed_in?
        @added_leaflets = Leaflet.where("id IN (?)", 
                                  MasterHeapLeafletMap.where("master_heap_id IN (?) AND created_at > ?", 
                                                       @rake.master_rake.master_heaps.pluck(:id), 
                                                       current_user.last_sign_in_at).pluck(:leaflet_id) -
                                  HeapLeafletMap.where("heap_id IN (?)",
                                                       @rake.heaps.pluck(:id)).pluck(:leaflet_id))
      end
      @feed_leaflets = @rake.feed_leaflets("news", params[:refresh]).order("published_at DESC").page(params[:page]).per(50)
      @new_channels = MasterRake.find(@rake.master_rake_id).channels
                                .where("channel_type <> 3 AND channel_type <> 5")
                                .order("created_at DESC")
                                .limit(5)
    elsif params[:view] == "bookmarks"
      @leaflet_types = CategoryLeafletTypeMap.where(category_id: @rake.master_rake.category_id).pluck(:leaflet_type_id)
      missing_leaflet_types = @leaflet_types - @rake.heaps.pluck(:leaflet_type_id)
      missing_leaflet_types.each do |mlt|
        @rake.add_heap(mlt)
      end
      if user_signed_in? && current_user.admin?
        @heaps = @rake.heaps
      else
        @leaflet_types.delete(15)
        @heaps = @rake.heaps.where.not(leaflet_type_id: 15)
      end
      @heap_ids = @heaps.pluck(:id)
      @leaflet_ids = HeapLeafletMap.where("heap_id IN (?)", @heap_ids).pluck(:leaflet_id)
      @heap_leaflets = Leaflet.where("id IN (?)", @leaflet_ids)
      @heap_collapse = params[:collapse].to_s.first(4) == "heap" ? "active" : ""
      @heap_id = params[:collapse].to_s.slice(5..-1)
    end
  end

  def search
    @rake = Myrake.find_by_name(params[:name])
    if @rake.nil?
      flash[:error] = "Couldn't find it, make sure you select a rake. Go to all rakes to discover other rakes."
      redirect_to rakes_path
    else
      redirect_to :controller => 'myrakes', :action => 'show', :id => @rake
    end
  end

  def new
    @rake = Myrake.new
    if !params[:master_rake_id].nil?
      @master_rake = MasterRake.find_by_id(params[:master_rake_id].to_i)
      @channels = @master_rake.channels.where("channel_type <> 5")
    end
  end

  def create_rake
    existing_rake = Myrake.where(user_id: current_user.id).find_by_master_rake_id(params[:master_rake_id])
    if existing_rake.nil?
      @rake = Myrake.new(rake_params)
      @rake.user_id = current_user.id
      if Myrake.where(user_id: current_user.id, top_rake: 1).count < 5
        @rake.top_rake = 1
      else
        @rake.top_rake = 0
      end
      if @rake.save
        master_rake = MasterRake.find(@rake.master_rake_id)
        master_rake.channels.each { |channel| @rake.add_channel(channel) unless channel.channel_type == 5 }
        master_rake.add_channel(@rake.channels.where(channel_type: 3).first)
        redirect_to myrake_path(@rake, view: "news", refresh: "yes")
      else
        flash[:error] = @rake.errors.full_messages
        redirect_to :back
      end
    else
      redirect_to myrake_path(existing_rake, view: "tasks")
    end
  end

  def create
    existing_rake = Myrake.where(user_id: current_user.id).find_by_master_rake_id(params[:myrake][:master_rake_id].to_i)
    if existing_rake.nil?
      @rake = Myrake.new(rake_params)
      if @rake.save
        master_rake = MasterRake.find(@rake.master_rake_id)
        master_rake.channels.each { |channel| @rake.add_channel(channel) unless channel.channel_type == 5 }
        master_rake.add_channel(@rake.channels.where(channel_type: 3).first)
        # if params[:myrake][:copy_recommendations] == "1"
        #   @heap_leaflets_maps = MasterHeapLeafletMap.where("master_heap_id IN (?)", master_rake.master_heaps.pluck(:id))
        #   @heap_leaflets_maps.each do |hl|
        #     leaflet = Leaflet.find(hl.leaflet_id)
        #     @rake.add_leaflet(leaflet, hl.master_heap.leaflet_type_id, leaflet.title, hl.leaflet_desc, "", "", "", 0, 0, 0)
        #   end
        # end
        redirect_to myrake_path(@rake, view: "tasks", refresh: "yes")
      else
        flash[:error] = @rake.errors.full_messages
        redirect_to :back
      end
    else
      redirect_to myrake_path(existing_rake, view: "tasks")
    end
  end

  def edit
    @rake = Myrake.find(params[:id])
    @master_rake = MasterRake.find_by_id(@rake.master_rake_id)
    @channels = @master_rake.channels.where("channel_type <> 5")
    if session[:displayed_channels].nil? || session[:displayed_channels].empty?
      session[:displayed_channels] = @channels.pluck(:id)
    else
      if params[:display_channel] == "yes"
        session[:displayed_channels] << params[:channel_id].to_i
      else
        session[:displayed_channels].delete(params[:channel_id].to_i)
      end
    end
    @feed_leaflets = @master_rake.feed_leaflets.where("channel_id IN (?)", session[:displayed_channels]).page(params[:page]).per(10)
  end

  def update
    @rake = Myrake.find(params[:id])
    if params[:commit] == "Commit Action"
      @leaflet = Leaflet.find(params[:myrake][:leaflet_id])
      heap_leaflet = HeapLeafletMap.where("heap_id = ? AND leaflet_id = ?", 
                                          params[:myrake][:heap_id].to_i, 
                                          params[:myrake][:leaflet_id].to_i).first
      case params[:myrake][:reminder_at].to_i
      when 0
        reminder_at = nil
      when 1
        reminder_at = Time.now + 1.hour
      when 2
        reminder_at = Time.now + 1.day
      when 3
        reminder_at = Time.now + 3.day
      when 4
        reminder_at = Time.now + 1.week
      when 5
        reminder_at = Time.now + 1.month
      else
        reminder_at = nil
      end
      params[:myrake][:current_score] == "1" ? motion_counter_increment = 1 : motion_counter_increment = 0
      params[:myrake][:current_score] == "2" ? action_counter_increment = 1 : action_counter_increment = 0
      heap_leaflet.update_attributes(leaflet_goal: params[:myrake][:leaflet_goal],
                                     leaflet_note: params[:myrake][:leaflet_note],
                                     reminder_at: reminder_at,
                                     current_score: params[:myrake][:current_score].to_i,
                                     current_rating: params[:myrake][:current_rating].to_i,
                                     action_counter: heap_leaflet.action_counter + action_counter_increment,
                                     motion_counter: heap_leaflet.motion_counter + motion_counter_increment)
      @leaflet.update_attributes(title: params[:myrake][:leaflet_title],
                                content: params[:myrake][:leaflet_desc],
                                url: params[:myrake][:leaflet_url])
      History.create!(user_id: current_user.id,
                     rake_id: @rake.id,
                     leaflet_id: @leaflet.id,
                     history_code: "bm_activity",
                     history_int: params[:myrake][:current_score].to_i,
                     history_int2: params[:myrake][:current_rating].to_i,
                     history_text: params[:myrake][:task_comment],
                     history_chain: params[:myrake][:history_chain].to_i)
      if params[:myrake][:origin] == "due" || params[:myrake][:origin] == "scheduled"
        respond_to do |format|
          format.html { redirect_to myrake_path(@rake, view: "tasks", origin: params[:myrake][:origin]) }
          format.js {
            @origin = params[:myrake][:origin]
            @chain_flag = params[:myrake][:current_score].to_i
            @leaflet_id = @leaflet.id
            if @origin == "due"
              @reload_flag = 0
            else
              @reload_flag = 1
            end
            render 'reminder_set'
          }
        end
      else
        redirect_to myrake_path(@rake,
                                view: "bookmarks",
                                collapse: params[:myrake][:collapse],
                                anchor: "anchor_leaflet_" +
                                        params[:myrake][:collapse].scan(/\d+$/).first +
                                        "_" +
                                        params[:myrake][:leaflet_id])
      end
    elsif params[:commit] == "Save Action"
      leaflet = Leaflet.find(params[:myrake][:leaflet_id])
      case params[:myrake][:reminder_at].to_i
      when 0
        reminder_at = nil
      when 1
        reminder_at = Time.now + 1.hour
      when 2
        reminder_at = Time.now + 1.day
      when 3
        reminder_at = Time.now + 3.day
      when 4
        reminder_at = Time.now + 1.week
      when 5
        reminder_at = Time.now + 1.month
      else
        reminder_at = nil
      end
      if @rake.add_leaflet(leaflet,
                        params[:myrake][:leaflet_type_id],
                        params[:myrake][:leaflet_title],
                        params[:myrake][:leaflet_desc],
                        params[:myrake][:leaflet_goal],
                        params[:myrake][:leaflet_note],
                        reminder_at,
                        params[:myrake][:current_score],
                        params[:myrake][:current_rating],
                        params[:myrake][:current_reminder])
        History.create(user_id: current_user.id,
                       rake_id: @rake.id,
                       leaflet_id: leaflet.id,
                       history_code: "bm_activity",
                       history_int: params[:myrake][:current_score].to_i,
                       history_int2: params[:myrake][:current_rating].to_i,
                       history_text: params[:myrake][:task_comment],
                       history_chain: params[:myrake][:history_chain].to_i)
        respond_to do |format|
          if session[:rake_class] == MasterRake
            format.html {
              redirect_to master_rake_path(@rake.master_rake_id,
                                           collapse: params[:myrake][:collapse],
                                           anchor: "anchor_leaflet_" + params[:myrake][:leaflet_id])
            }
            format.js {
              @leaflet_id = params[:myrake][:leaflet_id]
              render 'bookmark_saved'
            }
          else
            format.html {
              redirect_to myrake_path(@rake, view: "bookmarks", anchor: "anchor_leaflet_" + params[:myrake][:leaflet_id])
            }
            format.js {
              @leaflet_id = params[:myrake][:leaflet_id]
              render 'bookmark_saved'
            }
          end
        end
      else
        @error = "You have to select a category"
        respond_to do |format|
          if session[:rake_class] == MasterRake
            format.html { 
              flash[:error] = ["You have to select a category."]
              redirect_to master_rake_path(@rake.master_rake_id, collapse: params[:myrake][:collapse])
            }
            format.js { render 'shared/form_alert' }
          else
            format.html {
              flash[:error] = ["You have to select a category."]
              redirect_to myrake_path(@rake, collapse: params[:myrake][:collapse])
            }
            format.js { render 'shared/form_alert' }
          end
        end
      end
    elsif params[:commit] == "Create Bookmark"
      if params[:myrake][:leaflet_title].empty? || params[:myrake][:leaflet_desc].empty?
        url_data = @rake.url_data(params[:myrake][:leaflet_url])
      end
      if params[:myrake][:leaflet_title].empty?
        title = url_data[:leaflet_title]
      else
        title = params[:myrake][:leaflet_title]
      end
      if title.nil? || title.empty?
        title = params[:myrake][:leaflet_url]
      end
      if params[:myrake][:leaflet_desc].empty?
        description = url_data[:leaflet_desc]
      else
        description = params[:myrake][:leaflet_desc]
      end
      if description.empty?
        description = ""
      end
      if params[:myrake][:leaflet_type_id].to_i == 15
        leaflet_author = @rake.master_rake_id.to_s
      end
      case params[:myrake][:reminder_at].to_i
      when 0
        reminder_at = nil
      when 1
        reminder_at = Time.now + 1.hour
      when 2
        reminder_at = Time.now + 1.day
      when 3
        reminder_at = Time.now + 3.day
      when 4
        reminder_at = Time.now + 1.week
      when 5
        reminder_at = Time.now + 1.month
      else
        reminder_at = nil
      end
      leaflet_id = @rake.create_leaflet(params[:myrake][:leaflet_type_id],
                           title,
                           description,
                           params[:myrake][:leaflet_goal],
                           params[:myrake][:leaflet_note],
                           params[:myrake][:leaflet_url],
                           leaflet_author,
                           reminder_at,
                           params[:myrake][:current_score],
                           params[:myrake][:current_rating],
                           params[:myrake][:current_reminder])
      if !leaflet_id.nil?
        History.create!(user_id: current_user.id,
                       rake_id: @rake.id,
                       leaflet_id: leaflet_id,
                       history_code: "bm_activity",
                       history_int: params[:myrake][:current_score].to_i,
                       history_int2: params[:myrake][:current_rating].to_i,
                       history_text: params[:myrake][:task_comment],
                       history_chain: params[:myrake][:history_chain].to_i)
        redirect_to myrake_path(@rake,
                                view: "bookmarks",
                                anchor: "anchor_leaflet_" + params[:myrake][:leaflet_type_id] + "_" + leaflet_id.to_s)
      else
        flash[:error] = @rake.leaflet_errors.full_messages.to_sentence
        redirect_to myrake_path(@rake, heap_type: params[:myrake][:leaflet_type_id])
      end
    elsif params[:commit] == "Create Action"
      if params[:myrake][:leaflet_url].nil? || params[:myrake][:leaflet_url].empty?
        url = ""
        title = "None"
        description = "None"
        leaflet_type_id = "1"
      else
        url = params[:myrake][:leaflet_url]
        url_data = @rake.url_data(url)
        title = url_data[:leaflet_title]
        description = url_data[:leaflet_desc]
        leaflet_type_id = params[:myrake][:leaflet_type_id]
      end
      if leaflet_type_id.to_i == 15
        leaflet_author = @rake.master_rake_id.to_s
      end
      case params[:myrake][:reminder_at].to_i
      when 0
        reminder_at = nil
      when 1
        reminder_at = Time.now + 1.hour
      when 2
        reminder_at = Time.now + 1.day
      when 3
        reminder_at = Time.now + 3.day
      when 4
        reminder_at = Time.now + 1.week
      when 5
        reminder_at = Time.now + 1.month
      else
        reminder_at = nil
      end
      leaflet_id = @rake.create_leaflet(leaflet_type_id,
                           title,
                           description,
                           params[:myrake][:leaflet_goal],
                           params[:myrake][:leaflet_note],
                           url,
                           leaflet_author,
                           reminder_at,
                           params[:myrake][:current_score].to_i,
                           params[:myrake][:current_rating],
                           params[:myrake][:current_reminder])
      if !leaflet_id.nil?
        History.create!(user_id: current_user.id,
                       rake_id: @rake.id,
                       leaflet_id: leaflet_id,
                       history_code: "bm_activity",
                       history_int: params[:myrake][:current_score].to_i,
                       history_int2: params[:myrake][:current_rating].to_i,
                       history_text: params[:myrake][:task_comment],
                       history_chain: params[:myrake][:history_chain].to_i)
        redirect_to myrake_path(@rake, view: "tasks", origin: "scheduled")
      else
        flash[:error] = @rake.leaflet_errors.full_messages.to_sentence
        redirect_to myrake_path(@rake, view: "tasks", origin: "scheduled")
      end
    elsif params[:commit] == "Add Bookmark Category"
      @rake.add_heap(params[:myrake][:leaflet_type_id])
      redirect_to myrake_path(@rake, heap_type: params[:myrake][:leaflet_type_id])
    elsif params[:commit] == "Copy Bookmark"
      heapleaflet = HeapLeafletMap.where(heap_id: params[:myrake][:heap_id].to_i).find_by_leaflet_id(params[:myrake][:leaflet_id].to_i)
      target_rake = Myrake.where(user_id: current_user.id).find_by_name(params[:myrake][:name])
      leaflet = Leaflet.find(heapleaflet.leaflet_id)
      leaflet.update_attributes(updated_at: Time.now)
      if target_rake.add_leaflet(leaflet,
                                 params[:myrake][:leaflet_type_id].to_i,
                                 heapleaflet.leaflet_title,
                                 heapleaflet.leaflet_desc,
                                 "",
                                 "",
                                 "",
                                 0,
                                 0,
                                 0)
        redirect_to myrake_path(@rake,
                                view: "bookmarks",
                                collapse: "heap_#{heapleaflet.leaflet_type_id}"),
                                :notice => ["Bookmark copied."]
      else
        redirect_to myrake_path(@rake,
                                view: "bookmarks",
                                collapse: "heap_#{heapleaflet.leaflet_type_id}"),
                                :notice => ["Bookmark couldn't be copied. It probably exists already."]
      end
    else
      redirect_to myrake_path(@rake, view: "news")
    end
  end

  def destroy
    rake = Myrake.find(params[:id])
    rake.destroy
    redirect_to user_path(current_user), :notice => ["Rake deleted."]
  end

  def add_channel
    @rake = Myrake.find(params[:id])
    @rake.add_channel(Channel.find(params[:channel]))
    redirect_to myrake_path(@rake, view: "news")
  end

  def remove_channel
    @rake = Myrake.find(params[:id])
    if !params[:channel].nil?
      @channel = Channel.find(params[:channel])
      @rake.remove_channel(@channel)
      respond_to do |format|
        format.html { redirect_to myrake_path(@rake, view: "news") }
        format.js { render 'remove_channel' }
      end
    end
  end

  def toggle_channel_display
    @rake = Myrake.find(params[:id])
    @channel = Channel.find(params[:channel])
    display = params[:display] == "true"
    @rake.toggle_channel_display(@channel, display)
    respond_to do |format|
      format.html { redirect_to myrake_path(@rake, view: "news") }
    end
  end

  def toggle_top_rake
    @rake = Myrake.find(params[:id])
    if @rake.top_rake == 0 
      @rake.update_attributes(top_rake: 1)
      respond_to do |format|
        format.html { redirect_to myrake_path(@rake, view: "news") }
        format.js { render 'add_to_top'}
      end
    else
      @rake.update_attributes(top_rake: 0)
      respond_to do |format|
        format.html { redirect_to myrake_path(@rake, view: "news") }
        format.js { render 'remove_from_top'}
      end
    end
  end

  def get_url_title
    respond_to do |format|
      format.html { render :nothing }
      format.js { "Hello" }
    end
  end

  protected

  def rake_params
    params.permit(:name, :master_rake_id, :user_id, :feed_leaflets, :rake_filters, :top_rake)
  end
end
