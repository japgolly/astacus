class AlbumsHaveAlbumart < ActiveRecord::Migration
  def self.up
    add_column :audio_tags, :albumart_id, :integer
    add_index :audio_tags, :albumart_id

    add_column :albums, :albumart_id, :integer
    add_index :albums, :albumart_id
  end

  def self.down
    remove_column :audio_tags, :albumart_id
    remove_column :albums, :albumart_id
  end
end
