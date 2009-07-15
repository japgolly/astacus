class CreateScannerErrors < ActiveRecord::Migration
  def self.up
    create_table :scanner_errors do |t|
      t.integer :location_id, :null => false
      t.text :file, :limit => 2048+256, :null => false
      t.text :err_msg, :null => false
      t.timestamps
    end
    add_index :scanner_errors, :location_id
  end

  def self.down
    drop_table :scanner_errors
  end
end
