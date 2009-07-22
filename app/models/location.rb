class Location < ActiveRecord::Base
  has_many :scanner_errors, :order => 'file'
  has_many :scanner_logs, :order => 'started'
  attr_readonly :dir
  validates_presence_of :dir, :label
  validates_uniqueness_of :dir

  def before_validation
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

  def scan_async
    return false unless self.exists?
    MiddleMan.worker(:scanner_worker).async_scan(:arg => self)
  end
end
