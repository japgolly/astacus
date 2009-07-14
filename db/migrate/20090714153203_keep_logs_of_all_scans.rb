class KeepLogsOfAllScans < ActiveRecord::Migration
  def self.up
    create_table :scanner_logs do |t|
      t.references :location, :null => false
      t.datetime :started, :null => false
      t.datetime :ended
      t.integer :files_scanned
      t.integer :file_count
      t.boolean :active, :null => false
      t.boolean :aborted, :null => false, :default => false
    end
    add_index :scanner_logs, [:location_id, :active]
  end

  def self.down
    drop_table :scanner_logs
  end
end
