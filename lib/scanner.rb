require 'lib/in_memory_file'

module Astacus
  # Scans a dir tree looking for audio files.
  class Scanner

    def scan(dir)

    end

    def files_in(dir)
      Dir[File.join dir, '**', '*.mp3']
    end

    # Processes an audio file and creates/updates a record in the DB.
    def scan_file!(file)
      AudioFile.transaction do
      
        f= AudioFile.new
        f.dirname= File.dirname(file)
        f.basename= File.basename(file)
        f.size= File.size(file)

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

        # Finalise audio content
        a.size= content.size
        a.md5= Digest::MD5.digest(content)
        a.sha2= Digest::SHA2.digest(content, 512)
        a= AudioContent.find_identical(a) || a
        f.audio_content= a

        # Save
        a.save! if a.new_record?
        f.save!
        tags.each{|t| t.save!}
      end
    end

  end
end