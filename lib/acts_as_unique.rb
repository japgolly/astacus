require 'active_record'

module Acts
  module Unique
    def self.included(base)
      base.extend Acts::Unique::ClassMethods
    end

    module ClassMethods
      def acts_as_unique(options={})
        options.symbolize_keys!
        options.assert_valid_keys(:only, :except, :secondary)
        raise "Specify either :only or :except, not both." if options[:only] and options[:except]
        options[:except]= [] unless options[:only] or options[:except]

        cattr_accessor :acts_as_unique_cols
        cattr_accessor :acts_as_unique_col_filter
        cattr_accessor :acts_as_unique_cols_secondary
        self.acts_as_unique_cols= [(options[:only] || options[:except])].flatten.map(&:to_sym).uniq
        self.acts_as_unique_cols.concat [:id, :updated_at, :created_at] if options[:except]
        self.acts_as_unique_col_filter= options[:only] ? :select : :reject
        self.acts_as_unique_cols_secondary= [options[:secondary]].flatten.reject(&:nil?).map(&:to_s).sort.uniq

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
        secondary_cols= self.acts_as_unique_cols_secondary
        unless secondary_cols.empty?
          missing= secondary_cols - attributes.keys
          raise "Invalid column(s): #{missing.inspect}" unless missing.empty?
          attributes.delete_if {|k,v| secondary_cols.include? k}
        end
        conditions= {}
        attributes.each{|k,v| conditions[k]= v}

        matches= find :all, :conditions => conditions
        if !secondary_cols.empty? and matches.size > 1
          matches= matches.select{|m| compare(secondary_cols, obj, m) }
        end
        matches.first
      end

      def find_identical_or_create!(attributes)
        obj= self.new(attributes)
        obj.find_identical_or_save!
      end

      private
        def compare(cols, a, b)
          cols.each{|col| return false unless a[col] == b[col] }
          true
        end
    end

    module InstanceMethods
      def find_identical
        before_validation
        before_validation_on_create
        self.class.find_identical self
      end

      def find_identical_or_save!
        obj= unique
        obj.save! if obj.new_record?
        obj
      end
      alias_method :unique!, :find_identical_or_save!

      def unique
        find_identical || self
      end
    end
  end
end

ActiveRecord::Base.send(:include, Acts::Unique)
