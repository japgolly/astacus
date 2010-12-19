require 'test_helper'

class DiscTest < ActiveSupport::TestCase
  should have_many(:tracks)
  should belong_to(:album)
  should belong_to(:album_type)
  %w[album order_id].each{|attr|
    should validate_presence_of(attr)
  }
  should validate_numericality_of(:order_id)

  context "A disc" do
    should "have tracks" do
      assert_equal [tracks(:glass_prison), tracks(:misunderstood)], discs(:'6doit_cd1').tracks
    end

    should "order its tracks by tn" do
      t= tracks(:glass_prison)
      t.tn= 9
      t.save!
      assert_equal [tracks(:misunderstood), tracks(:glass_prison)], discs(:'6doit_cd1').tracks(true)
      t.tn= 1
      t.save!
      assert_equal [tracks(:glass_prison), tracks(:misunderstood)], discs(:'6doit_cd1').tracks(true)
    end

    should "belong to an album" do
      assert_equal albums(:'6doit'), discs(:'6doit_cd1').album
    end

    should "belong to an album type" do
      assert_equal album_types(:std), discs(:'6doit_cd1').album_type
    end

    should "provide a total disc length" do
      assert_equal 372, discs(:ponk).length
      assert_equal 129.463+215.719, discs(:still_life_1).length
    end

    should "provide a total disc size" do
      assert_equal 11494512, discs(:ponk).size
      assert_equal 3108860+5179014, discs(:still_life_1).size
    end

    should "provide all formats used by track files" do
      disc= discs(:still_life_1)
      assert_equal ['mp3'], disc.formats

      disc.tracks[0].audio_file.audio_content.format= 'flac'
      assert_equal ['flac','mp3'], disc.formats
    end

    should "provide an average bitrate" do
      assert_equal 247, discs(:ponk).avg_bitrate

      disc= discs(:still_life_1)
      assert_equal 192, disc.avg_bitrate

      disc.tracks[0].audio_file.audio_content.length= 1000
      disc.tracks[1].audio_file.audio_content.length= 1000
      disc.tracks[0].audio_file.audio_content.bitrate= 100
      disc.tracks[1].audio_file.audio_content.bitrate= 200
      assert_equal 150, disc.avg_bitrate
    end

    should "provide an average bitrate that takes length into consideration" do
      disc= discs(:still_life_1)
      disc.tracks[0].audio_file.audio_content.bitrate= 100
      disc.tracks[1].audio_file.audio_content.bitrate= 400
      disc.tracks[0].audio_file.audio_content.length= 20 # 100kbps for 20 sec
      disc.tracks[1].audio_file.audio_content.length= 10 # 400kbps for 10 sec
      assert_equal 200, disc.avg_bitrate # (100 + 100 + 400) / 3 = 200
    end
  end

  context "Deleting a disc" do
    should "not remove the album if other discs reference it" do
      assert_difference 'Disc.count', -1 do
        assert_difference 'Album.count', 0 do
          discs(:'6doit_cd1').destroy
        end
      end
    end

    should "decrement the parent album's disc counter" do
      a= albums("6doit")
      assert_difference 'a.reload; a.discs_count', -1 do
        discs(:'6doit_cd1').destroy
      end
    end

    should "remove the album if no other discs reference it" do
      assert_difference %w[Disc.count Album.count], -1 do
        discs(:ponk).destroy
      end
    end
  end
end
