class AddDiscCounterCacheToAlbums < ActiveRecord::Migration
  def self.up
    add_column :albums, :discs_count, :integer, :default => 0, :null => false
    Album.find(:all, :include => :discs).each{|a| a.discs_count= a.discs.size; a.save!}
  end

  def self.down
    remove_column :albums, :discs_count
  end
end
