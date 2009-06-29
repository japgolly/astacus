class Artist < ActiveRecord::Base
  has_many :albums
  validates_presence_of :name
  acts_as_unique
end
