require 'active_record'

module Acts
  module Unique
    def self.included(base)
      base.extend Acts::Unique::ClassMethods
    end

    module ClassMethods
      def acts_as_unique(options={:except => [:id, :updated_at, :created_at]})
        options.symbolize_keys!
        options.assert_valid_keys(:only, :except)
        raise "Specify either :only or :except, not both." if options[:only] and options[:except]

        cattr_accessor :acts_as_unique_cols
        cattr_accessor :acts_as_unique_col_filter
        self.acts_as_unique_cols= (options[:only] || options[:except]).map(&:to_sym).uniq
        self.acts_as_unique_col_filter= options[:only] ? :select : :reject

        class_eval <<-END
          include Acts::Unique::InstanceMethods
        END
      end

      # Finds a model with identical attributes (if it exists)
      def find_identical(obj)
        return nil if obj.nil?
        raise "#{obj.class} is not a #{self}." unless obj.is_a?(self)

        attributes= obj.attributes.send(self.acts_as_unique_col_filter) {|k,v|
          self.acts_as_unique_cols.include? k.to_sym
        }
        conditions= {}
        attributes.each{|k,v| conditions[k]= v}

        find :first, :conditions => conditions
      end

      def find_identical_or_create!(attributes)
        obj= self.new(attributes)
        obj.find_identical_or_save!
      end
    end

    module InstanceMethods
      def find_identical
        self.class.find_identical self
      end

      def find_identical_or_save!
        obj= reuse
        obj.save! if obj.new_record?
        obj
      end

      def reuse
        find_identical || self
      end
    end
  end
end

ActiveRecord::Base.send(:include, Acts::Unique)
