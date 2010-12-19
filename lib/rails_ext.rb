module RailsExt
  module ActiveRecord

    module ClassAndInstanceMethods
      # Nicely outputs a title and collection of variables to the log as debug-level.
      def log_vars(title, hash)
        l= logger rescue @logger
        if l and l.debug?
          values= hash.keys.map{|k| "    \e[33m#{k}\e[0m: #{hash[k]}"}.join "\n"
          l.debug "  \e[4;33;1m#{title}\e[0m\n#{values}"
        end
      end
    end # module ClassAndInstanceMethods

    module ClassMethods
      include ClassAndInstanceMethods
    end # module ClassMethods

    module InstanceMethods
      include ClassAndInstanceMethods
    end # module InstanceMethods
  end
end

ActiveRecord::Base.send :include, RailsExt::ActiveRecord::InstanceMethods
ActiveRecord::Base.send :extend, RailsExt::ActiveRecord::ClassMethods
