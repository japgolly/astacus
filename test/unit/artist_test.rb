require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  should_have_many :albums
  should_validate_presence_of :name
  should_validate_uniqueness_of :name, :case_sensitive => true
  should_not_allow_values_for :name, '', '   ', :message => "can't be blank"

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

    should "reuse existing if already exists" do
      a= nil
      assert_difference 'Artist.count', 0 do
        a= Artist.find_identical_or_create!(:name => 'Dream Theater')
      end
      assert !a.new_record?
      assert_equal 'Dream Theater', a.name
    end

    should "reference their va tracks" do
      assert_equal [], artists(:seikima2).va_tracks
      assert_same_elements [tracks(:maar_daala)], artists('kavita_subramaniam_k.k.').va_tracks
      assert_same_elements [tracks(:silsila_ye_chaahat_ka),tracks(:bairi_piya)], artists(:shreya_ghosal).va_tracks
    end

    should "be considered in use if referenced by either track or album" do
      assert artists(:seikima2).in_use?
      assert artists(:shreya_ghosal).in_use?
      assert_equal false, Artist.create(:name=>'ssh').in_use?
    end
  end
end
