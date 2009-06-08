class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :album_types do |t|
      t.string :name, :null => false, :unique => true
    end

    create_table :artists do |t|
      t.string :name, :null => false, :unique => true
      t.timestamps
    end

    create_table :albums do |t|
      t.integer :artist_id, :null => false
      t.string :name, :null => false
      t.integer :year
      t.integer :original_year
      t.timestamps
    end

    create_table :cds do |t|
      t.integer :album_id, :null => false
      t.integer :album_type_id
      t.string :name
      t.integer :order_id, :null => false
      t.timestamps
    end

    create_table :tracks do |t|
      t.integer :cd_id, :null => false
      t.integer :audio_file_id, :null => false
      t.integer :tn
      t.string :name, :null => false
      t.integer :length
      t.timestamps
    end

    create_table :audio_files do |t|
      t.string :dirname, :null => false
      t.string :basename, :null => false
      t.string :format, :null => false
      t.integer :size
      t.integer :bitrate
      t.timestamps
    end
  end

  def self.down
    drop_table :audio_files
    drop_table :tracks
    drop_table :cds
    drop_table :albums
    drop_table :artists
    drop_table :album_types
  end
end
