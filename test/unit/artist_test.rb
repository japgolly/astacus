require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  should_have_many :albums
  should_validate_presence_of :name

  test "has albums" do
    assert_equal [albums(:'6doit')], artists(:dream_theater).albums
  end
end
