require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  should_belong_to :disc
  should_belong_to :audio_file
  should_belong_to :track_artist
  should_have_and_belong_to_many :audio_tags
  %w[disc audio_file name].each{|attr|
    should_validate_presence_of attr
  }
  should_validate_numericality_of :tn

  test "belongs to disc" do
    assert_equal discs(:'6doit_cd2'), tracks(:about_to_crash).disc
  end

  test "belongs to audio_file" do
    assert_equal audio_files(:about_to_crash), tracks(:about_to_crash).audio_file
  end

  test "belong to audio_tags" do
    assert_same_elements [
      audio_tags(:apsog_x_id3),
      audio_tags(:apsog_x_ape),
    ], tracks(:apsog_x).audio_tags
  end

  context "Deleting a track" do
    should "not remove the disc if other tracks reference it" do
      assert_difference 'Track.count', -1 do
        assert_difference %w[Artist.count Album.count Disc.count], 0 do
          tracks(:misunderstood).destroy
        end
      end
    end

    should "remove the disc if no other tracks reference it" do
      assert_difference %w[Track.count Disc.count], -1 do
        assert_difference %w[Artist.count Album.count], 0 do
          tracks(:about_to_crash).destroy
        end
      end
    end

    should "remove up to the artist if not in use" do
      assert_equal 1, albums(:ponk).discs_count
      assert_difference %w[Track.count Disc.count Artist.count Album.count], -1 do
        tracks(:the_requiem).destroy
      end
    end

    should "remove track artist if it's no longer referenced" do
      t= tracks(:kaahe_chhed_mohe)
      assert_difference 'Artist.count', -1 do
        t.destroy
      end
      assert !Artist.exists?(t.track_artist_id)
    end

    should "not remove track artist it's still being referenced" do
      assert_difference 'Artist.count', 0 do
        tracks(:bairi_piya).destroy
      end
    end
  end
end
