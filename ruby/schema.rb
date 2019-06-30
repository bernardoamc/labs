module TypedParameters
  class Schema
    class << self
      def define(&block)
        new(&block)
      end
    end

    attr_reader :schema

    def initialize(&block)
      @schema = {}

      instance_eval(&block) if block_given?
    end

    def attribute(field, type, optional: false, default: nil)
      @schema[field] = Attribute.new(type, optional, default)
    end

    class Attribute
      def initialize(type, optional, default)
        @type = type
        @optional = optional
        @default = default
      end
    end
  end
end

a = TypedParameters::Schema.define do
  attribute :foo, :strong, optional: true
  attribute :bar, :strong, default: 'yay'
end

p a.schema
