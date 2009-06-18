require 'test_helper'
require 'lib/scanner.rb'

class ScannerTest < ActiveSupport::TestCase
  context "The Scanner" do
    setup do
      @scanner= Astacus::Scanner.new
    end

    should "find audio files" do
      assert_equal [
        "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像/02 - Frozen City.mp3"
      ], @scanner.files_in(mock_data_dir)
    end

    should "record new files in db" do
      file= "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像/02 - Frozen City.mp3"
      assert File.exists?(file)
      assert_difference ['AudioContent.count','AudioFile.count'], +1 do
        assert_difference 'AudioTag.count', +1 do
          @scanner.scan_file! file
        end
      end

      # AudioFile
      f= AudioFile.last
      assert_equal AudioContent.last, f.audio_content
      assert_equal "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像", f.dirname
      assert_equal "02 - Frozen City.mp3", f.basename
      assert_equal 68177, f.size
      assert_not_nil f.created_at
      assert_not_nil f.updated_at

      # AudioTag
      t1= f.audio_tags[0]
      assert_equal 'id3', t1.format
      assert_equal '2.4.0', t1.version
      assert_equal 0, t1.offset
      assert_equal 9088, t1.data.size

      # AudioContent
      a= f.audio_content
      assert_equal 68177 - f.audio_tags.inject(0){|s,t| s+t.data.size}, a.size
      assert_equal 'mp3', a.format
      assert_equal 160, a.bitrate
      assert_equal 2.95445, a.length
      assert_equal 44100, a.samplerate
      assert_equal false, a.vbr?
      assert_not_nil f.created_at
      assert_not_nil f.updated_at
    end
  end
end
