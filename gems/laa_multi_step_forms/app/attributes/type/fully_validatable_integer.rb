module Type
  class FullyValidatableInteger < ActiveModel::Type::Integer
    def cast(value)
      if value.is_a?(Integer) || value.blank? || value.strip.gsub(/[0-9,-]/, '').empty?
        super(value&.to_s&.delete(','))
      else
        # If the user has entered a string that is not straightforwardly parseable
        # as an integer, retain the original value so we can display it back to the user
        value
      end
    end
  end
end
