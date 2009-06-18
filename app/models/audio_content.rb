class AudioContent < ActiveRecord::Base
  has_many :audio_files

  attr_readonly :size, :md5, :sha2, :format
  validates_presence_of :size, :md5, :sha2, :format
  validates_length_of :md5, :is => 16, :tokenizer => lambda {|v| v}
  validates_length_of :sha2, :is => 64, :tokenizer => lambda {|v| v}
end
