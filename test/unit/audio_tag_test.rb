require 'test_helper'

class AudioTagTest < ActiveSupport::TestCase
  should_belong_to :audio_file
  should_belong_to :albumart
  should_have_and_belong_to_many :tracks
  %w[audio_file format offset data].each{|attr|
    should_validate_presence_of attr
  }
  should_validate_positive_numericality_of :offset

  context "AudioTags based on APE tags" do
    setup do
      file= "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像/02 - Frozen City.mp3"
      @at= AudioTag.new({
          :format => 'ape',
          :version => '2',
          :data => ApeTag.new(file).raw
        })
    end

    should "provide basic tag attributes" do
      assert_equal '聖飢魔II', @at.artist
      assert_equal 'メフィストフェレスの肖像', @at.album
      assert_equal '凍てついた街', @at.track
      assert_equal 1996, @at.year
    end

    should "understand consolidated tn fields" do
      assert_equal 2, @at.tn
    end
  end

  context "AudioTags based on ID3v2 tags" do
    setup do
      file= "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像/02 - Frozen City.mp3"
      Mp3Info.open(file){|mp3|
        start,len= mp3.audio_content
        @at= AudioTag.new({
            :format => 'id3',
            :version => mp3.tag2.version,
            :data => File.read(file)[0..start-1],
        })
      }
    end

    should "provide basic tag attributes" do
      assert_equal '聖飢魔II', @at.artist
      assert_equal 'メフィストフェレスの肖像', @at.album
      assert_equal '凍てついた街', @at.track
      assert_equal 1996, @at.year
    end

    should "understand consolidated tn fields" do
      assert_equal 2, @at.tn
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
