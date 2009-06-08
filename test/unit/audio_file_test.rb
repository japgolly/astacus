require 'test_helper'

class AudioFileTest < ActiveSupport::TestCase

  test "has tracks" do
    assert_equal [tracks(:misunderstood)], audio_files(:misunderstood).tracks
  end
end
