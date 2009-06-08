class Album < ActiveRecord::Base
  belongs_to :artist
  has_many :cds, :order => :order_id
end
