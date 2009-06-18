require 'test_helper'

class AudioContentTest < ActiveSupport::TestCase
  should_have_many :audio_files
  %w[size md5 sha2 format].each{|attr|
    should_validate_presence_of attr
    should_have_readonly_attributes attr
  }
  should_ensure_length_is :md5, 16
  should_ensure_length_is :sha2, 64
end
