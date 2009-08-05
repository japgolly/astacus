require 'test_helper'

class AudioTagTest < ActiveSupport::TestCase
  should_belong_to :audio_file
  should_belong_to :albumart
  should_have_and_belong_to_many :tracks
  %w[audio_file format offset data].each{|attr|
    should_validate_presence_of attr
  }
  should_validate_positive_numericality_of :offset

  def create_ape_audio_tag_from_file(file)
    AudioTag.new({
      :format => 'ape',
      :version => '2',
      :data => ApeTag.new(file).raw
    })
  end

  def create_id3_audio_tag_from_file(file)
      at= nil
      Mp3Info.open(file){|mp3|
        start,len= mp3.audio_content
        at= AudioTag.new({
            :format => 'id3',
            :version => mp3.tag2.version,
            :data => File.read(file)[0..start-1],
        })
      }
      at
  end

  context "AudioTags based on APE tags" do
    context "from non-VA albums" do
      setup do
        @at= create_ape_audio_tag_from_file SEIKIMA_CD2_08
      end

      should "provide basic tag attributes" do
        assert_equal '聖飢魔II', @at.artist
        assert_equal '愛と虐殺の日々', @at.album
        assert_nil @at.album_artist
        assert_equal '赤い玉の伝説', @at.track
        assert_equal 1991, @at.year
      end

      should "understand consolidated tn fields" do
        assert_equal 8, @at.tn
      end

      should "understand consolidated disc fields" do
        assert_equal 2, @at.disc
      end
    end

    context "from VA albums" do
      setup do
        @at= create_ape_audio_tag_from_file DEVDAS_2
      end

      should "provide basic tag attributes" do
        assert_equal 'Kavita Subramaniam, K.K.', @at.artist
        assert_equal 'Devdas (देवदास)', @at.album
        assert_equal 'Various Artists', @at.album_artist
        assert_equal 'Maar Daala (मार डाला)', @at.track
        assert_equal 2002, @at.year
      end
    end
  end

  context "AudioTags based on ID3v2 tags" do
    context "from non-VA albums" do
      setup do
        @at= create_id3_audio_tag_from_file SEIKIMA_CD2_08
      end

      should "provide basic tag attributes" do
        assert_equal '聖飢魔II', @at.artist
        assert_equal '愛と虐殺の日々', @at.album
        assert_nil @at.album_artist
        assert_equal '赤い玉の伝説', @at.track
        assert_equal 1991, @at.year
      end

      should "understand consolidated tn fields" do
        assert_equal 8, @at.tn
      end

      should "understand consolidated disc fields" do
        assert_equal 2, @at.disc
      end
    end

    context "from VA albums" do
      setup do
        @at= create_id3_audio_tag_from_file DEVDAS_2
      end

      should "provide basic tag attributes" do
        assert_equal 'Kavita Subramaniam, K.K.', @at.artist
        assert_equal 'Devdas (देवदास)', @at.album
        assert_equal 'Various Artists', @at.album_artist
        assert_equal 'Maar Daala (मार डाला)', @at.track
        assert_equal 2002, @at.year
      end
    end
  end

  context "Deleting an audio tag" do
    should "remove the track as well if not referenced by other tags" do
      assert_difference %w[AudioTag.count Track.count count_audio_tags_tracks], -1 do
        audio_tags(:glass_prison_id3).destroy
      end
    end

    should "not remove the track if referenced by other tags" do
      assert_difference 'Track.count', 0 do
        assert_difference %w[AudioTag.count count_audio_tags_tracks], -1 do
          audio_tags(:the_requiem_id3).destroy
        end
      end
    end
  end
end
