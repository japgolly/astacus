require 'mp3info'

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
      r= AudioFile.new
      r.dirname= File.dirname(file)
      r.basename= File.basename(file)
      r.format= r.basename.sub(/^.+\./,'') if r.basename.include?('.')
      r.size= File.size(file)
      if r.format =~ /mp3/
        mp3= Mp3Info.new(file)
        r.bitrate= mp3.bitrate
      end
      r.save!
    end

  end
end