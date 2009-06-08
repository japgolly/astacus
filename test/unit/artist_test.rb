require 'test_helper'

class ArtistTest < ActiveSupport::TestCase

  test "has albums" do
    assert_equal [albums(:'6doit')], artists(:dream_theater).albums
  end
end
