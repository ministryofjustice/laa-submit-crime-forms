module Type
  class ValueObject < ActiveModel::Type::Value
    attr_reader :source, :array

    def initialize(*args, **kwargs)
      @source = kwargs.delete(:source)
      @array = kwargs.delete(:array)
      super
    end

    def type
      :value_object
    end

    def cast(value)
      return value&.map { |v| cast_value(v) } if array
      super
    end

    def serialize(value)
      if array
        value.map(&:value).to_json
      else
        value.to_s
      end

    end

    def ==(other)
      if array
        return false unless other.array
        return false unless source.size == other.source.size
        source&.zip(other.source)&.all? { |l, r| l == r }
      else
        self.class == other.class && source == other.source
      end
    end
    alias eql? ==

    def hash
      if array
        source.flat_map { |v| [v.class, v.source] }.hash
      else
        [self.class, source].hash
      end
    end

    def type_cast_for_schema
      if array
        source&.map(&:source)&.to_json
      else
        super
      end
    end

    private

    def cast_value(value)
      case value
      when String, Symbol
        source.new(value)
      when source
        value
      end
    end
  end
end
