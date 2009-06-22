require 'active_record'

module Acts
  module Unique
    def self.included(base)
      base.extend Acts::Unique::ClassMethods
    end

    module ClassMethods
      def acts_as_unique
        class_eval <<-END
          include Acts::Unique::InstanceMethods
        END
      end

      # Finds a model with identical attributes (if it exists)
      def find_identical(obj)
        return nil if obj.nil?
        raise "#{obj.class} is not a #{self}." unless obj.is_a?(self)
        attributes= obj.attributes.dup
        %w[id updated_at created_at].each{|k| attributes.delete k}
        unless count == 0
          puts
          require 'pp'
          pp attributes
          pp((find :first).attributes.to_hash)
          puts
        end
        find :first, :conditions => attributes
      end
    end

    module InstanceMethods
    end
  end
end

ActiveRecord::Base.send(:include, Acts::Unique)
