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
      t.references :artist, :null => false
      t.string :name, :null => false
      t.integer :year
      t.integer :original_year
      t.timestamps
    end

    create_table :discs do |t|
      t.references :album, :null => false
      t.references :album_type
      t.string :name
      t.integer :order_id, :null => false
      t.timestamps
    end

    create_table :tracks do |t|
      t.references :disc, :null => false
      t.integer :tn
      t.string :name, :null => false
      t.integer :length
      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
    drop_table :discs
    drop_table :albums
    drop_table :artists
    drop_table :album_types
  end
end
