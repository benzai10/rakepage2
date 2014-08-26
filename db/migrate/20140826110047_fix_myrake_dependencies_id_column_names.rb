class FixMyrakeDependenciesIdColumnNames < ActiveRecord::Migration
  def change
    rename_column :rake_channel_maps, :rake_id, :myrake_id
    rename_column :filters, :rake_id, :myrake_id
    rename_column :heaps, :rake_id, :myrake_id
  end
end
