require 'test_helper'
require 'lib/scanner.rb'

class ScannerTest < ActiveSupport::TestCase
  setup :new_scanner

  def new_scanner
    @scanner= Astacus::Scanner.new
  end

  test "finds the right files" do
    assert_equal [
      "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像/02 - Frozen City.mp3"
    ], @scanner.files_in(mock_data_dir)
  end

  test "records a new file" do
    file= "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像/02 - Frozen City.mp3"
    assert File.exists?(file)
    assert_difference 'AudioFile.count', +1 do
      @scanner.scan_file! file
    end
    f= AudioFile.last
    assert_equal "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像", f.dirname
    assert_equal "02 - Frozen City.mp3", f.basename
    assert_equal 'mp3', f.format
    assert_equal 68177, f.size
    assert_equal 160, f.bitrate
    assert_not_nil f.created_at
    assert_not_nil f.updated_at
  end
end
