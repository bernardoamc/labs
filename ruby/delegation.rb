class Menu < ActiveRecord::Base
  TYPES_MAPPING = {
    'blog' => BlogLink,
    'page' => PageLink,
  }.freeze

  validate :custom_type_validation

  delegate :to_path, :to_s, to: :type_object

  private

  def type_object
    TYPES_MAPPING.fetch(type) { raise 'TypeNotImplemented' }
  end

  def custom_type_validation
    type_object.validate
  end
end

class BlogLink
  def validate
    # Specific BlogLink validation
  end

  def to_path
    "/blogs"
  end

  def to_s
    'BlogLink'
  end
end
