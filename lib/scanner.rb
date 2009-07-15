module Astacus
  # Scans a dir tree looking for audio files.
  class Scanner

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
              ScannerError.create :location => @location, :file => file, :err_msg => err.to_s
            end
          end
          sl.files_scanned+= file_batch.size
          sl.save!
        else
          sl.aborted= true
        end
      }

      # Done
      @location= nil
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
      
        f= AudioFile.new({
          :dirname => File.dirname(file),
          :basename => File.basename(file),
          :size => File.size(file),
          :location => @location,
        })
        tags= []
        a= AudioContent.new
        content= File.read(file)
        file_ext= f.basename.sub(/^.+\./,'') if f.basename.include?('.')
        if file_ext =~ /mp3/i
          a.format= 'mp3'
          Mp3Info.open(file){|mp3|
            start,len= mp3.audio_content

            # Read ID3 tag
            tags<< AudioTag.new({
                :audio_file => f,
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
                  :audio_file => f,
                  :format => 'ape',
                  :version => '2',
                  :offset => f.size - ape.tag_size,
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

        # Finalise audio content
        a.size= content.size
        a.md5= Digest::MD5.digest(content)
        a.sha2= Digest::SHA2.digest(content, 512)
        a= a.unique
        f.audio_content= a

        # Save
        a.save! if a.new_record?
        f.save!
        tags.each{|t| t.save!}

        # Create artist/album/cd/track
        albums= []
        tags.each{|t|
          if t.useable?
            artist= Artist.find_identical_or_create! :name => t.artist
            album= Album.find_identical_or_create!({
              :artist => artist,
              :name => t.album,
              :year => t.year,
            })
            albums<< album
            cd= Cd.find_identical_or_create!({
              :album => album,
              :order_id => 0,
            })
            Track.find_identical_or_create!({
              :cd => cd,
              :name => t.track,
              :tn => t.tn,
              :audio_file => f,
            })
          end
        }

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
    end # scan_file!

  end
end