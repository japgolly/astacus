class Track < ActiveRecord::Base
  belongs_to :cd
  belongs_to :audio_file

  validates_presence_of :cd, :audio_file, :name
  validates_numericality_of :tn, :only_integer => true, :allow_nil => true
end
