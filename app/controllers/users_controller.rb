class UsersController < ApplicationController
  respond_to :html, :json

  def show
    if user_signed_in?
      if params[:id] == current_user.id || params[:id] == current_user.slug
        History.create!(user_id: current_user.id,
                        history_code: "user_show")
        # @utc_offset = Time.find_zone(cookies[:timezone]).utc_offset
        @top_rakes = Myrake.where(user_id: current_user.id, top_rake: 1)
        @other_rakes = Myrake.where(user_id: current_user.id, top_rake: 0)
        @committed_action_steps_count = History.where(user_id: current_user.id, history_int2: 1).count
        @committed_action_goals_count = History.where(user_id: current_user.id, history_int2: 2).count
        @notifications = Notification.all.order(published_at: :desc)
        @master_rakes_count = MasterRake.all.count
        if params[:view] == "top5"
          @top5_active = "active"
          @status_active = ""
        else
          @top5_active = ""
          @status_active = "active"
        end
      else
        redirect_to master_rakes_path
        return
      end
    else
      redirect_to master_rakes_path
    end
  end

  def update
    if params[:commit] == "Save Bookmark"
      leaflet = Leaflet.find(params[:user][:leaflet_id])
      myrake = Myrake.where(user_id: current_user.id, name: params[:user][:rake_name]).first
      myrake.add_leaflet(leaflet, params[:user][:leaflet_type_id], leaflet.title, "", nil)
      redirect_to master_rakes_path(collapse: "recommendations", anchor: "leaflet_" + leaflet.id.to_s)
    elsif params[:commit] == "Update Bookmark"
      @leaflet = Leaflet.find(params[:user][:leaflet_id])
      heap_leaflet = HeapLeafletMap.where("heap_id = ? AND leaflet_id = ?", 
                                          params[:user][:heap_id].to_i, 
                                          params[:user][:leaflet_id].to_i).first
      @reminder_at = params[:user][:reminder_at].to_i
      case @reminder_at
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
      params[:user][:current_score] == "1" ? motion_counter_increment = 1 : motion_counter_increment = 0
      params[:user][:current_score] == "2" ? action_counter_increment = 1 : action_counter_increment = 0
      heap_leaflet.update_attributes(leaflet_goal: params[:user][:leaflet_goal],
                                     leaflet_note: params[:user][:leaflet_note],
                                     reminder_at: reminder_at,
                                     current_score: params[:user][:current_score].to_i,
                                     current_rating: params[:user][:current_rating].to_i,
                                     scheduled_counter: params[:user][:scheduled_counter].to_i,
                                     action_counter: heap_leaflet.action_counter + action_counter_increment,
                                     motion_counter: heap_leaflet.motion_counter + motion_counter_increment)
      current_rake = Heap.find(params[:user][:heap_id].to_i).myrake
      History.create!(user_id: current_user.id,
                     rake_id: current_rake.id,
                     leaflet_id: @leaflet.id,
                     history_code: "bm_activity",
                     history_int: params[:user][:current_score].to_i,
                     history_int2: params[:user][:current_rating].to_i,
                     history_str: params[:user][:task_comment],
                     history_chain: params[:user][:history_chain].to_i)
      respond_to do |format|
        format.html { 
          if params[:user][:origin] == "overdue"
            redirect_to user_path(current_user, collapse: "reminders")
          else
            redirect_to user_path(current_user, collapse: "scheduled_reminders")
          end
        }
        format.js {
          if params[:user][:origin] == "overdue" || (params[:user][:origin] == "scheduled" && @reminder_at == 0)
            if current_rake.top_rake == 1 && params[:user][:current_score].to_i > 0
              @top_rake_id = current_rake.id
              if params[:user][:current_score] == "1"
                @score_int = 1
              else
                @score_int = 2
              end
            else
              @top_rake_id = 0
              @score_int = 0
            end
            @origin = params[:user][:origin]
            @reload_flag = 0
            render 'myrakes/reminder_set'
          else
            @top_rake_id = 0
            @score_int = 0
            @origin = params[:user][:origin]
            @reload_flag = 1
            render 'myrakes/reminder_set'
          end
        }
      end
    else
      redirect_to master_rakes_path
    end
  end

  def notification_read
    respond_to do |format|
      format.js {
        if user_signed_in?
          User.find(current_user).update_attributes(last_notification_read_at: Time.now)
          render nothing: true
        end
      }
    end
  end

end