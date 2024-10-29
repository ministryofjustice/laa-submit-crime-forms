module Type
  class FullyValidatableFloat < ActiveModel::Type::Float
    def cast(value)
      if value.is_a?(Integer) || value.is_a?(Float) || value.blank? || remove_commas(value).is_a?(Float)
        super(remove_commas(value))
      else
        # If the user has entered a string that is not straightforwardly parseable
        # as an integer, retain the original value so we can display it back to the user
        value
      end
    end

    private

    def remove_commas(value)
      value&.to_s&.delete(',')
    end
  end
end
