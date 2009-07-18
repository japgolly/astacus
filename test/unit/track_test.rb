require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  should_belong_to :cd
  should_belong_to :audio_file
  should_have_and_belong_to_many :audio_tags
  %w[cd audio_file name].each{|attr|
    should_validate_presence_of attr
  }
  should_validate_numericality_of :tn

  test "belongs to cd" do
    assert_equal cds(:'6doit_cd2'), tracks(:about_to_crash).cd
  end

  test "belongs to audio_file" do
    assert_equal audio_files(:about_to_crash), tracks(:about_to_crash).audio_file
  end

  context "Deleting a track" do
    should "not remove the cd if other tracks reference it" do
      assert_difference 'Track.count', -1 do
        assert_difference %w[Artist.count Album.count Cd.count], 0 do
          tracks(:misunderstood).destroy
        end
      end
    end

    should "remove the cd if no other tracks reference it" do
      assert_difference %w[Track.count Cd.count], -1 do
        assert_difference %w[Artist.count Album.count], 0 do
          tracks(:about_to_crash).destroy
        end
      end
    end

    should "remove up to the artist if not in use" do
      assert_difference %w[Track.count Cd.count Artist.count Album.count], -1 do
        tracks(:the_requiem).destroy
      end
    end
  end
end
