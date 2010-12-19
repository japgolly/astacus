require 'test_helper'

class AudioFileTest < ActiveSupport::TestCase
  should belong_to :audio_content
  should belong_to :location
  should have_many :audio_tags
  should have_many :tracks
  %w[audio_content dirname basename size mtime].each{|attr|
    should validate_presence_of attr
  }
  should_validate_positive_numericality_of :size
  should_not allow_value('2006 - パレード/06 - 雪が降らない街.mp3').for(:basename) #, :message => 'must be greater than or equal to 0'
  #TODO should_not allow_value('2006 - パレード/06 - 雪が降らない街.mp3').for(:basename).with_message('must be greater than or equal to 0')

  context "An audio file" do
    should "return its file extention" do
      assert_equal 'mp3', AudioFile.new(:basename => 'as.mp3').file_ext
      assert_equal 'flac', AudioFile.new(:basename => 'asasd asd.asdad qwe.mp3.flac').file_ext
    end

    should "return its mimetype" do
      assert_equal 'audio/mpeg', AudioFile.new(:basename => 'as.mp3').mimetype
      assert_equal 'audio/flac', AudioFile.new(:basename => 'asasd asd.asdad qwe.mp3.flac').mimetype
    end

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
