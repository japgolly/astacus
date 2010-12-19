class AlbumType < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => { :case_sensitive => false, :allow_blank => false, :allow_nil => true }
end
