class AlbumType < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, :allow_blank => false, :allow_nil => true
end
