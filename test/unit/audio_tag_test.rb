require 'test_helper'

class AudioTagTest < ActiveSupport::TestCase
  should_belong_to :audio_file
  %w[audio_file format offset data].each{|attr|
    should_validate_presence_of attr
  }
end
