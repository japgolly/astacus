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

      # Takes an options hash that find() does and returns a raw sql select statement.
      def get_raw_sql(options)
        # base.rb, find()
        validate_find_options(options)
        set_readonly_option!(options)
        # base.rb, find_every()
        include_associations = merge_includes(scope(:find, :include), options[:include])
        if include_associations.any? && references_eager_loaded_tables?(options)
          # associations.rb, find_with_associations()
          join_dependency = JoinDependency.new(self, merge_includes(scope(:find, :include), options[:include]), options[:joins])
          construct_finder_sql_with_included_associations(options, join_dependency)
        else
          # base.rb, find_every()
          construct_finder_sql(options)
        end
      end
    end # module ClassMethods

    module InstanceMethods
      include ClassAndInstanceMethods
    end # module InstanceMethods
  end
end

ActiveRecord::Base.send :include, RailsExt::ActiveRecord::InstanceMethods
ActiveRecord::Base.send :extend, RailsExt::ActiveRecord::ClassMethods
