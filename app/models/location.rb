class Location < ActiveRecord::Base
  attr_readonly :dir
  validates_presence_of :dir, :label
  validates_uniqueness_of :dir

  def before_validation
    unless dir.blank?
      self.dir= `cygpath -au #{dir.inspect}`.chomp if RUBY_PLATFORM =~ /cygwin/i
      self.dir= File.expand_path(dir)
    end
  end
end
