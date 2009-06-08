class Cd < ActiveRecord::Base
  has_many :tracks, :order => :tn
  belongs_to :album
  belongs_to :album_type
end
