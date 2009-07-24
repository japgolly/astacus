class IndexImageSizes < ActiveRecord::Migration
  def self.up
    add_index :images, :size
  end

  def self.down
    remove_index :images, :column => :size
  end
end
