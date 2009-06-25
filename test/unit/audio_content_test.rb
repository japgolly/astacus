require 'test_helper'

class AudioContentTest < ActiveSupport::TestCase
  should_have_many :audio_files
  %w[size md5 sha2 format].each{|attr|
    should_validate_presence_of attr
    should_have_readonly_attributes attr
  }
  should_ensure_length_is :md5, 16
  should_ensure_length_is :sha2, 64
  should_validate_positive_numericality_of :bitrate
  should_validate_positive_numericality_of :length
  should_validate_positive_numericality_of :samplerate

  context "AudioContent" do
    setup do
      @identical= AudioContent.create(:size => 127, :md5 => 'a'*16, :sha2 => 'b'*64, :format => 'mp3')
      @ac= AudioContent.last.clone
      @ac.updated_at= @ac.created_at= nil
    end

    should "not be reused when size, checksums and format differ" do
      {:size => 666, :md5 => 'c'*16, :sha2 => 'd'*64, :format => 'mp4'}.each{|k,v|
        a= @ac.clone
        a[k]= v
        assert_find_identical nil, a
      }
    end

    should "be still reused when non-relevant attributes differ" do
      @ac.length= 100
      @ac.bitrate= 90
      @ac.samplerate= 100
      @ac.vbr= !@ac.vbr?
      assert_find_identical @identical, @ac
    end
  end

  def assert_find_identical(expected, ac)
    assert_equal expected, AudioContent.find_identical(ac)
    assert_equal expected, ac.find_identical
  end
end
