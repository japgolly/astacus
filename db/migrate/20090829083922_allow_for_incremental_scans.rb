class AllowForIncrementalScans < ActiveRecord::Migration
  def self.up
    add_column :audio_files, :mtime, :datetime, :null => false
    update_audio_file_mtimes
    add_index :audio_files, :mtime
  end

  def self.down
    remove_column :audio_files, :mtime
  end

  private
  def self.update_audio_file_mtimes
    say_with_time "Updating audio file mtimes..." do
      audio_files= AudioFile.find(:all)
      total= audio_files.length
      say "#{total} found.", true
      unless total == 0
        i= 0
        audio_files.each {|f|
          begin
            mtime= File.mtime(f.filename)
            AudioFile.update f.id, :mtime => mtime
          rescue Errno::ENOENT
            # ignore missing files
          rescue => e
            $stderr.puts e
          end
          i+= 1
          say("  [#{i}/#{total}]", true) if i == total or i % 1000 == 0
        }
      end
    end
  end
end
