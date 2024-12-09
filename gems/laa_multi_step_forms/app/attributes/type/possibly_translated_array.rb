module Type
  class PossiblyTranslatedArray < ActiveModel::Type::Value
    # This is for attributes where eeach will either be of format "x"
    # or of format { "en" => "Some string", "value" => "x" }
    def cast(values)
      mapped = values&.map do |value|
        value.is_a?(String) ? value : value['value']
      end

      super(mapped)
    end
  end
end
