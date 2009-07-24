require File.join(File.dirname(__FILE__) + "/../bdrb_test_helper")
#require 'test_helper'
require 'scanner_worker'

class ScannerWorkerTest < ActiveSupport::TestCase

  context "The Scanner" do
    setup do
      @location= locations(:downloads)
      @scanner= ScannerWorker.new
      @scanner.instance_variable_set :@location, @location
    end

    should "find audio files" do
      assert_same_elements [
        FROZEN_CITY_TAGGED,
        FROZEN_CITY_NOTAGS,
        BOUM_BOUM_YULA,
        SEIKIMA_CD1_06,
        SEIKIMA_CD1_13,
        SEIKIMA_CD2_08,
      ], @scanner.files_in(mock_data_dir)
    end

    should "not attempt to convert unicode tag strings to ansi" do
      # Don't know why the Japanese tags pass but u with an umlat doesnt
      assert_difference 'Track.count' do
        @scanner.scan_file! BOUM_BOUM_YULA
      end
      assert_equal 'Boum Boum Yüla', Track.last.name
    end

    context "when scanning a new file" do
      setup do
        @file= FROZEN_CITY_TAGGED
        assert File.exists?(@file)
        @ac_count= AudioContent.count
        @af_count= AudioFile.count
        @at_count= AudioTag.count
        @track_count= Track.count
        @cd_count= Cd.count
        @album_count= Album.count
        @artist_count= Artist.count
        @image_count= Image.count
        @scanner.scan_file! @file
        @f= AudioFile.last unless @af_count == AudioFile.count
      end

      should "create a new audio file row" do
        assert_equal @af_count+1, AudioFile.count
        assert_equal AudioContent.last, @f.audio_content
        assert_equal "#{mock_data_dir}/聖飢魔II/Albums/1996 - メフィストフェレスの肖像", @f.dirname
        assert_equal "02 - Frozen City.mp3", @f.basename
        assert_equal 68177, @f.size
        assert_not_nil @f.created_at
        assert_not_nil @f.updated_at
        assert_equal @location, @f.location
      end

      should "create a new audio content row" do
        assert_equal @ac_count+1, AudioContent.count
        a= @f.audio_content
        assert_equal 58723, a.size
        assert_equal 'mp3', a.format
        assert_equal 160, a.bitrate
        assert_equal 2.93615, a.length
        assert_equal 44100, a.samplerate
        assert_equal false, a.vbr?
        assert_not_nil a.created_at
        assert_not_nil a.updated_at
      end

      should "store the id3 tag" do
        assert_equal @at_count+2, AudioTag.count
        t1= @f.audio_tags.select{|t| t.offset == 0}[0]
        assert_equal 'id3', t1.format
        assert_equal '2.4.0', t1.version
        assert_equal 0, t1.offset
        assert_equal 9088, t1.data.size
        assert_equal 1, t1.tracks.size
      end

      should "store the ape tag" do
        t2= @f.audio_tags.select{|t| t.offset > 0}[0]
        assert_equal 'ape', t2.format
        assert_equal '2', t2.version
        assert_equal 68177-359, t2.offset
        assert_equal 359, t2.data.size
        assert_equal 1, t2.tracks.size
      end

      should "create a new track" do
        assert_equal @track_count+1, Track.count
        assert_equal @album_count+1, Album.count
        assert_equal @cd_count+1, Cd.count
        assert_equal @artist_count, Artist.count
        t= Track.last
        assert_equal '凍てついた街', t.name
        assert_equal 2, t.tn
        assert_equal @f, t.audio_file
        assert_nil t.cd.name
        assert_equal 0, t.cd.order_id
        assert_equal 'メフィストフェレスの肖像', t.cd.album.name
        assert_equal 1996, t.cd.album.year
        assert_equal '聖飢魔II', t.cd.album.artist.name
        assert_equal 2, t.audio_tags.size
      end

      should "extract and save the album art from id3 tags" do
        assert_equal @image_count+1, Image.count
        tag= @f.audio_tags.select{|t| t.offset == 0}[0]
        pic= tag.ta['APIC']
        img= Image.last
        assert_equal 7750-14, img.data.size
        assert_equal img.size, img.data.size
        assert_equal pic[14..-1], img.data
        assert_equal "image/jpeg", img.mimetype
        assert_equal img, tag.albumart
        assert_equal img, Album.last.albumart(true)
      end
    end

    should "reuse existing audio_content when it matches" do
      # Scan tagged version first
      assert_difference 'AudioContent.count', +1 do
        @scanner.scan_file! FROZEN_CITY_TAGGED
      end

      # Scan untagged version next
      assert_difference ['AudioContent.count','AudioTag.count'], 0 do
        assert_difference 'AudioFile.count', +1 do
          @scanner.scan_file! FROZEN_CITY_NOTAGS
        end
      end
      f= AudioFile.last
      assert_equal mock_data_dir, f.dirname
      assert_equal "frozen city (no tags).mp3", f.basename
      assert_equal 58723 , f.size
      assert_not_nil f.audio_content
      assert_equal 2, f.audio_content.audio_files.count
    end

    should "keep logs" do
      def @scanner.scan_file!(file)
        @during= @sl.attributes
      end
      loc= locations(:mock_data_dir)
      assert_difference 'ScannerLog.count', 1 do
        @scanner.scan loc
      end

      # Check completed
      sl= ScannerLog.last
      assert_equal loc, sl.location
      assert_not_nil sl.ended
      assert sl.file_count > 1
      assert_equal sl.file_count, sl.files_scanned
      assert !sl.aborted?
      assert !sl.active?

      # Check during
      sl= ScannerLog.new(@scanner.instance_variable_get(:@during))
      assert_equal loc, sl.location
      assert_nil sl.ended
      assert sl.file_count > 1
      assert !sl.aborted?
      assert sl.active?
    end

    should "record errors" do
      def @scanner.files_in(dir)
        ['file_that_doesnt_exist1','file_that_doesnt_exist2']
      end
      loc= locations(:mock_data_dir)
      assert_difference 'ScannerError.count', 2 do
        @scanner.scan loc
      end
      se= ScannerError.last
      assert_equal loc, se.location
      assert_equal 'file_that_doesnt_exist2', se.file
      assert_match /No such file or directory/, se.err_msg
    end

    should "remove errors when successful" do
      file= FROZEN_CITY_TAGGED
      ScannerError.create :location => locations(:mock_data_dir), :file => '123', :err_msg => 'asd'
      se= ScannerError.create :location => locations(:mock_data_dir), :file => file, :err_msg => 'asd'
      ScannerError.create :location => locations(:mock_data_dir), :file => 'bca', :err_msg => 'asd'
      assert_difference 'ScannerError.count', -1 do
        @scanner.scan_file! file
      end
      assert_does_not_contain ScannerError.find(:all), se
    end

    context "when scanning the same file" do
      setup do
        @file= FROZEN_CITY_TAGGED
        assert File.exists?(@file)
        @scanner.scan_file! @file
        @prev_counts= table_counts
      end

      should "not recreate any existing rows" do
        @scanner.scan_file! @file
        assert_equal @prev_counts, table_counts
      end

      should "replace incorrect tracks" do
        t= Track.last; t.tn= 99; t.save!
        AudioTag.update_all 'data="qwe"'
        @scanner.scan_file! @file
        assert_equal 2, Track.last.tn
        assert_equal @prev_counts, table_counts
      end
    end # context

    context "when scanning files with cds" do
      should "create a cd row if a new cd" do
        # Cd 1
        assert_difference 'Cd.count' do
          @scanner.scan_file! SEIKIMA_CD1_06
        end
        cd= Cd.last
        assert "CD 1", cd.name
        assert 1, cd.order_id

        # Cd 2
        assert_difference 'Cd.count' do
          @scanner.scan_file! SEIKIMA_CD2_08
        end
        cd= Cd.last
        assert "CD 2", cd.name
        assert 2, cd.order_id
      end

      should "reuse an existing cd row if exists" do
        assert_difference 'Cd.count' do
          @scanner.scan_file! SEIKIMA_CD1_06
        end
        assert_difference 'Cd.count', 0 do
          @scanner.scan_file! SEIKIMA_CD1_13
        end
      end
    end

  end # context: The scanner
end