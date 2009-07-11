class Image < ActiveRecord::Base
  attr_readonly :size, :data, :mimetype
  validates_presence_of :size, :data, :mimetype
  acts_as_unique

  def before_validation_on_create
    self.size= data.size if attribute_present?(:data)
  end
end
