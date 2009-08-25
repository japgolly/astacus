require 'bdrb_test_helper'
require 'scanner_worker'

class ScannerWorkerTest < ActiveSupport::TestCase
  ScannerWorker.log_scanner_errors_to_stderr= false

  context "The Scanner" do
    setup do
      @location= locations(:mock_data_dir)
      @scanner= ScannerWorker.new
      @scanner.init @location
    end

    should "correctly derive the basename of files with utf8 filenames" do
      assert_difference 'AudioFile.count' do
        @scanner.scan_file! GOGO7188
      end
      af= AudioFile.last
      assert_equal '06 - 雪が降らない街.mp3', af.basename
      assert_equal "#{MOCK_DATA_DIR}/GO!GO!7188/Albums/2006 - パレード", af.dirname
    end

    should "find audio files" do
      assert_same_elements ALL_MOCK_DATA_FILES, @scanner.files_in(mock_data_dir)
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
        @disc_count= Disc.count
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
        t= @f.audio_tags.select{|t| t.offset == 0}[0]
        assert_equal 'id3', t.format
        assert_equal '2.4.0', t.version
        assert_equal 0, t.offset
        assert_equal 9088, t.data.size
        assert_equal 1, t.tracks.size
      end

      should "store the ape tag" do
        t= @f.audio_tags.select{|t| t.offset > 0}[0]
        assert_equal 'ape', t.format
        assert_equal '2', t.version
        assert_equal 68177-359, t.offset
        assert_equal 359, t.data.size
        assert_equal 1, t.tracks.size
      end

      should "create a new track" do
        assert_equal @track_count+1, Track.count
        assert_equal @album_count+1, Album.count
        assert_equal @disc_count+1, Disc.count
        assert_equal @artist_count, Artist.count
        t= Track.last
        assert_equal '凍てついた街', t.name
        assert_equal 2, t.tn
        assert_equal 2.93615, t.length
        assert_equal @f, t.audio_file
        assert_nil t.disc.name
        assert !t.disc.va?
        assert_equal 0, t.disc.order_id
        assert_equal 'メフィストフェレスの肖像', t.disc.album.name
        assert_equal 1996, t.disc.album.year
        assert_equal 1, t.disc.album.discs_count
        assert_equal '聖飢魔II', t.disc.album.artist.name
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
        ['file_that_doesnt_exist/1','file_that_doesnt_exist/2']
      end
      loc= locations(:mock_data_dir)
      assert_difference 'ScannerError.count', 2 do
        @scanner.scan loc
      end
      se= ScannerError.last
      assert_equal loc, se.location
      assert_equal 'file_that_doesnt_exist/2', se.file
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

      context "without changes" do
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
      end # Context: without changes

      context "an albumart change" do
        should "update the existing rows and replace the image" do
          # Scan the first file
          prepare_tag_change_test TAGCHANGE_ALBUMART_BEFORE, TAGCHANGE_ALBUMART_AFTER

          # Scan the second
          assert_difference %w[AudioFile.count Album.count Disc.count Track.count Image.count], 0 do
            @scanner.scan_file! TAGCHANGE_ALBUMART_AFTER
          end
          assert_equal 213779, AudioFile.last.size
          assert_equal 80644, Image.last.size
        end
      end # Context: with an albumart change

      context "a track name change" do
        should "update the existing rows and replace the track" do
          # Scan the first file
          prepare_tag_change_test TAGCHANGE_TRACK_BEFORE, TAGCHANGE_TRACK_AFTER
          assert_equal 'maggic', Track.last.name

          # Scan the second
          assert_difference %w[AudioFile.count Album.count Disc.count Track.count Image.count], 0 do
            @scanner.scan_file! TAGCHANGE_TRACK_AFTER
          end
          assert_equal 213741, AudioFile.last.size
          assert_equal 'Magic', Track.last.name
        end
      end # Context: with a track name change

    end # Context: when scanning the same file

    context "when scanning files with discs" do
      should "create a disc row if a new disc" do
        # Disc 1
        assert_difference 'Disc.count' do
          @scanner.scan_file! SEIKIMA_CD1_06
        end
        disc= Disc.last
        assert "Disc 1", disc.name
        assert 1, disc.order_id
        album= disc.album
        assert_equal 1, album.discs_count

        # Disc 2
        assert_difference 'Disc.count' do
          @scanner.scan_file! SEIKIMA_CD2_08
        end
        disc= Disc.last
        assert "Disc 2", disc.name
        assert 2, disc.order_id
        album.reload
        assert_equal 2, album.discs_count
      end

      should "reuse an existing disc row if exists" do
        assert_difference 'Disc.count' do
          @scanner.scan_file! SEIKIMA_CD1_06
        end
        assert_difference 'Disc.count', 0 do
          @scanner.scan_file! SEIKIMA_CD1_13
        end
      end

      should "handle discs with letters and subtitles" do
        assert_difference 'Disc.count' do
          @scanner.scan_file! DJANGO
        end
        d= Disc.last
        assert_equal 'Disc B: Paris 1939-40', d.name
        assert_equal 66, d.order_id
      end
    end

    context "when there are dead files" do
      setup do
        # There are audio file text fixtures set to the mock_data_dir location
        # for other tests. They are outside the scope of these scanner dead-file
        # tests so this update is to make sure they don't poulte our results.
        AudioFile.update_all "location_id = #{locations(:main).id}",
          "location_id = #{locations(:mock_data_dir).id}"

        assert_equal 0, @location.audio_files.size
        assert_difference 'AudioFile.count' do
          @scanner.scan_file! FROZEN_CITY_TAGGED
        end
        @dead= AudioFile.last

        @scanner.init @location.reload
        assert_difference 'AudioFile.count' do
          @scanner.scan_file! BOUM_BOUM_YULA
        end
        @alive= AudioFile.last

        @dead.basename= 'bullshit'
        @dead.save!
        @scanner.init @location.reload
      end

      should "remove them" do
        assert_difference %w[AudioFile.count Track.count Album.count], -1 do
          @scanner.remove_dead_files!
        end
        assert_equal 1, @location.audio_files(true).size
        assert_equal @alive, @location.audio_files.first
      end

      should "decrement the album disc counter cache when appropriate" do
        AudioFile.update_all "location_id = #{locations(:main).id}"
        audio_files(:apsog_i).update_attribute :location_id, @location.id
        audio_files(:apsog_ii).update_attribute :location_id, @location.id
        @scanner.init @location.reload
        a= albums(:still_life)
        assert_difference 'a.reload; a.discs_count', -1 do
          assert_difference 'Track.count', -2 do
            @scanner.remove_dead_files!
          end
        end
      end

      should "remove them as part of full scan" do
        assert @location.audio_files.map(&:basename).include?('bullshit')
        @scanner.scan @location
        assert_equal ALL_MOCK_DATA_FILES.size, @location.audio_files(true).size
        assert !@location.audio_files.map(&:basename).include?('bullshit')
      end

      should "clear the VA flag on a disc when necessary" do
        # TODO should clear the VA flag on a disc when necessary
        # only when the disc is already VA, has > 1 track and none of those are VA
      end
    end # context: when there are dead files

    context "when scanning VA albums" do
      setup do
        remove_devdas_test_fixture
      end

      should "use the album artist as the main artist and add the other artists to tracks" do
        assert_difference 'Artist.count', 2 do
          assert_difference 'Track.count' do
            @scanner.scan_file! DEVDAS_1
          end
        end
        t= Track.last
        assert_not_nil t.track_artist
        assert_equal 'Shreya Ghosal', t.track_artist.name
        assert_equal 'Various Artists', t.disc.album.artist.name

        assert_difference %w[Track.count Artist.count] do
          @scanner.scan_file! DEVDAS_2
        end
        t= Track.last
        assert_not_nil t.track_artist
        assert_equal 'Kavita Subramaniam, K.K.', t.track_artist.name
        assert_equal 'Various Artists', t.disc.album.artist.name
      end

      should "set the VA flag on the disc" do
        assert_difference 'Disc.count' do
          @scanner.scan_file! DEVDAS_1
        end
        disc= Disc.last
        assert disc.va?
      end
    end # context: when scanning VA albums

  end # context: The scanner

  def remove_devdas_test_fixture
    d= discs(:devdas)
    d.tracks.each{|t| t.delete}
    d.delete
    %w[
      va
      kavita_subramaniam_k.k.
      pt.birju_maharaj_kavita_subramaniam_madhuri_dixit
      shreya_ghosal
    ].each{|a| artists(a).delete}
  end

  def prepare_tag_change_test(before_file, after_file)
    # Scan the first file
    assert_difference 'AudioFile.count' do
      @scanner.scan_file! before_file
    end

    # Now hack so that it has the same filename as the second
    @af= AudioFile.last
    @af.basename= File.basename(after_file)
    @af.save!
    assert_equal File.basename(after_file), AudioFile.find(@af.id).basename

    @scanner.init @location.reload
  end
end
