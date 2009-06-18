class AudioTag < ActiveRecord::Base
  belongs_to :audio_file
  validates_presence_of :audio_file, :format, :offset, :data
end
