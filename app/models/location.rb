class Location < ActiveRecord::Base
  has_many :audio_files
  has_many :scanner_errors, :order => 'file'
  has_many :scanner_logs, :order => 'started'
  attr_readonly :dir
  validates :label, :presence => true
  validates :dir, :uniqueness => true, :presence => true
  # TODO make sure label cant contain any !,"'\s (including spaces)

  before_validation :preprocess_dir

  def preprocess_dir
    unless dir.blank?
      self.dir= `cygpath -au #{dir.inspect}`.chomp if RUBY_PLATFORM =~ /cygwin/i
      self.dir= File.expand_path(dir)
    end
  end

  def active_scanner_log
    scanner_logs.select{|sl| sl.active?}.last
  end

  def exists?
    File.exists?(dir) and File.directory?(dir)
  end

  def last_mtime
    AudioFile.maximum :mtime, :conditions => "location_id = #{id}" unless new_record?
  end

  def scan_async(full)
    return false unless self.exists?
    MiddleMan.worker(:scanner_worker).async_scan(:arg => [self,full])
  end
end
