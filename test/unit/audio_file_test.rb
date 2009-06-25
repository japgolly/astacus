require 'test_helper'

class AudioFileTest < ActiveSupport::TestCase
  should_belong_to :audio_content
  should_have_many :audio_tags
  should_have_many :tracks
  %w[audio_content dirname basename size].each{|attr|
    should_validate_presence_of attr
  }
  should_validate_positive_numericality_of :size

  context "An audio file" do

    should "provide a helper that returns the full path" do
      f= AudioFile.new(:dirname => mock_data_dir, :basename => 'asd').filename
      assert_equal File.expand_path("#{mock_data_dir}/asd"), f
    end

    should "provide a helper that checks whether the file exists" do
      assert_equal false, AudioFile.new(:dirname => mock_data_dir, :basename => 'asd').exists?
      assert_equal true, AudioFile.new(:dirname => "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像", :basename => "02 - Frozen City.mp3").exists?
    end
  end
end
