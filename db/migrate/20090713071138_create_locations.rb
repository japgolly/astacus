class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.text :dir, :null => false, :limit => 2048
      t.string :label, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
