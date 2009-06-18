require 'test_helper'

class TrackTest < ActiveSupport::TestCase

  test "belongs to cd" do
    assert_equal cds(:'6doit_cd2'), tracks(:about_to_crash).cd
  end

#  test "belongs to audio_file" do
#    assert_equal audio_files(:about_to_crash), tracks(:about_to_crash).audio_file
#  end
end
