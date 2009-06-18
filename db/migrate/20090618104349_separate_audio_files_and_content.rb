class SeparateAudioFilesAndContent < ActiveRecord::Migration
  def self.up
    create_table :audio_content do |t|
      t.integer :size, :null => false
      t.binary :md5, :null => false, :limit => 16
      t.binary :sha2, :null => false, :limit => 64
      t.string :format, :null => false
      t.integer :bitrate
      t.float :length
      t.integer :samplerate
      t.boolean :vbr
      t.timestamps
    end
    add_index :audio_content, :size

    create_table :audio_files do |t|
      t.references :audio_content, :null => false
      t.text :dirname, :null => false, :limit => 2048
      t.string :basename, :null => false
      t.integer :size, :null => false
      t.timestamps
    end

    create_table :audio_tags do |t|
      t.references :audio_file, :null => false
      t.string :format, :null => false, :limit => 8
      t.string :version, :limit => 10
      t.integer :offset, :null => false
      t.binary :data, :null => false, :limit => 2.megabytes
    end
  end

  def self.down
    drop_table :audio_tags
    drop_table :audio_files
    drop_table :audio_content
  end
end
