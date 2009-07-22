class ScannerWorker < BackgrounDRb::MetaWorker
  set_worker_name :scanner_worker

  def create(args=nil)
  end

  def scan(location)
    # Start
    @location= location
    sl= @sl= ScannerLog.new(:location => @location, :started => Time.now, :active => true)
    sl.save!

    # Find files
    files= files_in(@location.dir)
    sl.files_scanned= 0
    sl.file_count= files.size
    sl.save!

    # Process files
    files.in_groups_of(4, false) {|file_batch|
      sl.reload
      if sl.active? and not sl.aborted?
        file_batch.each do |file|
          begin
            scan_file! file
          rescue => err
            err_msg= err.to_s
            err_msg.gsub! /(x'[0-9a-f]{64})[0-9a-f]+'/, '\1...\''
            ScannerError.create :location => @location, :file => file, :err_msg => err_msg
          end
        end
        sl.files_scanned+= file_batch.size
        sl.save!
      else
        sl.aborted= true
      end
    }

    # Done
    @sl= @location= nil
    sl.ended= Time.now
    sl.active= false
    sl.save!
  end

  def files_in(dir)
    Dir[File.join dir, '**', '*.mp3']
  end

  # Processes an audio file and creates/updates a record in the DB.
  def scan_file!(file)
    AudioFile.transaction do

      file_basename= File.basename(file)
      filesize= File.size(file)
      tags= []
      a= AudioContent.new
      content= File.read(file)
      file_ext= file_basename.sub(/^.+\./,'') if file_basename.include?('.')
      if file_ext =~ /mp3/i
        a.format= 'mp3'
        Mp3Info.open(file){|mp3|
          start,len= mp3.audio_content

          # Read ID3 tag
          tags<< AudioTag.new({
              :format => 'id3',
              :version => mp3.tag2.version,
              :offset => 0,
              :data => content[0..start-1],
          }) if start > 0 and mp3.tag2
          # TODO footer id3 tags not supported
          content= content[start..start+len-1]

          # Read APE tag
          ape= ApeTag.new(file)
          if ape.exists?
            raise "ape.tag_size != ape.raw.size\n#{ape.inspect}" unless ape.tag_size == ape.raw.size
            tags<< AudioTag.new({
                :format => 'ape',
                :version => '2',
                :offset => filesize - ape.tag_size,
                :data => ape.raw,
            })
            content= content[0..-ape.tag_size-1]
          end
        }

        # Scan forward to mp3 header
        content.sub!(/^\x00+(?=\xff)/, '').freeze

        # Read mp3 attributes from raw mp3 without tags
        stringio_fake_filename= File.filename_for_stringio(content)
        Mp3Info.open(stringio_fake_filename){|mp3|
          a.bitrate= mp3.bitrate
          a.length= mp3.length
          a.samplerate= mp3.samplerate
          a.vbr= mp3.vbr
        }
      else
        raise "Unsupported format: #{file_ext.inspect}\nFile: #{file}"
      end

      # Albumart on tags
      tags.each{|t|
        if t.albumart_raw and t.albumart_mimetype
          img= Image.find_identical_or_create! :mimetype => t.albumart_mimetype, :data => t.albumart_raw
          t.albumart= img
        end
      }

      # Save audio content
      a.size= content.size
      a.md5= Digest::MD5.digest(content)
      a.sha2= Digest::SHA2.digest(content, 512)
      a= a.find_identical_or_save!

      # Save audio file
      f= AudioFile.find_identical_or_create!({
        :audio_content => a,
        :dirname => File.dirname(file),
        :basename => file_basename,
        :size => filesize,
        :location => @location,
      })

      # Save tags
      albums= []
      tags_to_delete= f.audio_tags.dup
      tags.each{|t|
        t.audio_file= f

        # Save if this is a new tag
        matching_tags= f.audio_tags.select{|t2| get_tag_attributes(t) == get_tag_attributes(t2)}
        if matching_tags.empty?
          t.save!
          process_tag t, albums, f
        else
          matching_tags.each{|t2| tags_to_delete.delete t2}
        end
      }
      f.audio_tags.delete *tags_to_delete unless tags_to_delete.empty?

      # Albumart on albums
      tags.each{|t|
        if albumart_raw= t.ta[:albumart]
          img= Image.find_identical_or_create! :data => albumart_raw, :size => albumart_raw.size
          t.albumart= img
        end
      }
      albums.uniq.each{|album| album.update_albumart!}
    end

    # Remove any errors for this file
    ScannerError.delete_all :file => file
  end

  def get_tag_attributes(tag)
    a= tag.attributes
    a.delete 'id'
    a
  end

  def process_tag(tag, albums, audio_file)
    return false unless tag.useable?

    # Create artist/album/cd/track
    artist= Artist.find_identical_or_create! :name => tag.artist
    album= Album.find_identical_or_create!({
      :artist => artist,
      :name => tag.album,
      :year => tag.year,
    })
    albums<< album
    cd= Cd.find_identical_or_create!({
      :album => album,
      :order_id => 0,
    })
    track= Track.find_identical_or_create!({
      :cd => cd,
      :name => tag.track,
      :tn => tag.tn,
      :audio_file => audio_file,
    })
    tag.tracks<< track
  end
end
