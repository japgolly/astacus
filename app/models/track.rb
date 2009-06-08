class Track < ActiveRecord::Base
  belongs_to :cd
  belongs_to :audio_file
end
