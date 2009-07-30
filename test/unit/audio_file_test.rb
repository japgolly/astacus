require 'test_helper'

class AudioFileTest < ActiveSupport::TestCase
  should_belong_to :audio_content
  should_belong_to :location
  should_have_many :audio_tags
  should_have_many :tracks
  %w[audio_content dirname basename size].each{|attr|
    should_validate_presence_of attr
  }
  should_validate_positive_numericality_of :size
  should_not_allow_values_for :basename, '2006 - パレード/06 - 雪が降らない街.mp3'#, :message => 'must be greater than or equal to 0'

  context "An audio file" do

    should "provide a helper that returns the full path" do
      f= AudioFile.new(:dirname => mock_data_dir, :basename => 'asd').filename
      assert_equal File.expand_path("#{mock_data_dir}/asd"), f
    end

    should "provide a helper that checks whether the file exists" do
      assert_equal false, AudioFile.new(:dirname => mock_data_dir, :basename => 'asd').exists?
      assert_equal true, AudioFile.new(:dirname => "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像", :basename => "02 - Frozen City.mp3").exists?
    end

    should "delete tags and tracks when deleting an associated tag" do
      assert_difference %w[AudioTag.count Track.count], -1 do
        af= audio_files(:glass_prison)
        af.audio_tags.delete af.audio_tags.first
      end
    end
  end
end
