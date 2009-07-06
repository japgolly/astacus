class TracksDontNeedLengths < ActiveRecord::Migration
  def self.up
    remove_column :tracks, :length
  end

  def self.down
    add_column :tracks, :length, :integer
  end
end
