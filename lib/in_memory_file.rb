unless File.respond_to?(:initialize_without_stringio_hack)

class File
  class StringIoStat
    attr_reader :size
    def initialize(content)
      @size= content.size
    end
  end

  alias_method :initialize_without_stringio_hack, :initialize
  def initialize(*args)
    filename= args[0]
    if File.is_stringio?(filename)
      @stringio= true
      @stringio_content= File.stringio_content(filename)
      @delegate= StringIO.new @stringio_content, *(args[1..-1])
      (@delegate.methods - Object.methods).each{|m|
        if m.to_s =~ /=$/
          instance_eval "def #{m}(a) @delegate.#{m}(a) end"
        else
          instance_eval "def #{m}(*args,&blck) @delegate.#{m}(*args,&blck) end"
        end
      }
    else
      initialize_without_stringio_hack(*args)
    end
  end

  alias_method :stat_without_stringio_hack, :stat
  def stat
    return stat_without_stringio_hack unless @stringio
    @stringio_stat||= StringIoStat.new(@stringio_content)
  end

  class << self
    def filename_for_stringio(content)
      "\000\000" + content
    end

    def is_stringio?(filename)
      filename && filename.starts_with?("\000\000")
    end

    def stringio_content(filename)
      return nil unless is_stringio?(filename)
      filename[2..-1]
    end

    alias_method :size_without_stringio_hack, :size
    def size(filename)
      if is_stringio?(filename)
        stringio_content(filename).size
      else
        size_without_stringio_hack(filename)
      end
    end

    alias_method :sizeQ_without_stringio_hack, :size?
    def size?(filename)
      if is_stringio?(filename)
        true
      else
        sizeQ_without_stringio_hack(filename)
      end
    end
  end
end

end
