class Artist < ActiveRecord::Base
  has_many :albums
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false, :allow_blank => false, :allow_nil => true
  acts_as_unique
end
