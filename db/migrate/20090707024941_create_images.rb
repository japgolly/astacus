class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :size, :null => false
      t.binary :data, :null => false
      t.string :mimetype, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
