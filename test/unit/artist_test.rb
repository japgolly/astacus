require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  should_have_many :albums
  should_validate_presence_of :name

  context "Artists" do
    should "have albums" do
      assert_equal [albums(:'6doit')], artists(:dream_theater).albums
    end

    should "be created if doesnt exist yet" do
      new_artist_name= 'Karnivool'
      a= nil
      assert_difference 'Artist.count', +1 do
        a= Artist.find_identical_or_create!(:name => new_artist_name)
      end
      assert !a.new_record?
      assert_equal new_artist_name, a.name
    end

    should "be reuse existing if already exists" do
      a= nil
      assert_difference 'Artist.count', 0 do
        a= Artist.find_identical_or_create!(:name => 'Dream Theater')
      end
      assert !a.new_record?
      assert_equal 'Dream Theater', a.name
    end
  end
end
