class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username, :null => false
      t.string :password, :null => false
      t.boolean :admin, :null => false, :default => 0
      t.timestamps
    end
    add_index :users, :username
    User.create :username => 'admin', :password => 'aaadm1n', :admin => true
  end

  def self.down
    drop_table :users
  end
end
