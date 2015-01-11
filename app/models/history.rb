class History < ActiveRecord::Base
  belongs_to :user

  validates :history_str, length: { maximum: 300 }
  validates :history_text, length: { maximum: 600 }

  def self.get_chain(rake_id, time_zone)
    motion_chain = self.where(rake_id: rake_id, history_int: 1)
                       .group_by_day(:created_at,
                                     range: Time.now - 29.day..Time.now,
                                     time_zone: time_zone)
                       .count.map{ |x| x[1] > 0 }
    action_chain = self.where(rake_id: rake_id, history_int: 2)
                       .group_by_day(:created_at,
                                     range: Time.now - 29.day..Time.now,
                                     time_zone: time_zone)
                       .count.map{ |x| x[1] > 0 }
    motion_chain.zip(action_chain)
  end

  def self.get_last_motion_or_action(rake_id)
    last_motion_or_action = self.where("rake_id = ? AND (history_int = 1 OR history_int = 2)", rake_id).last
    return last_motion_or_action
  end
end
