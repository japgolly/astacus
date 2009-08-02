class CreateSearchQueries < ActiveRecord::Migration
  def self.up
    create_table :search_queries do |t|
      t.string :name, :null => false
      t.text :params, :null => false
    end
    add_index :search_queries, :name, :unique => true
  end

  def self.down
    drop_table :search_queries
  end
end
