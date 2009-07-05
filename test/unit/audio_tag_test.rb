require 'test_helper'

class AudioTagTest < ActiveSupport::TestCase
  should_belong_to :audio_file
  %w[audio_file format offset data].each{|attr|
    should_validate_presence_of attr
  }
  should_validate_positive_numericality_of :offset

  context "AudioTags based on APE tags" do
    setup do
      @file= "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像/02 - Frozen City.mp3"
      @at= AudioTag.new({
          :format => 'ape',
          :version => '2',
          :data => ApeTag.new(@file).raw
        })
    end

    should "provide basic tag attributes"  do
      assert_equal '聖飢魔II', @at.artist
      assert_equal 'メフィストフェレスの肖像', @at.album
      assert_equal '凍てついた街', @at.track
      assert_equal 1996, @at.year
    end

    should "understand consolidated tn fields"  do
      assert_equal 2, @at.tn
    end
  end
end
