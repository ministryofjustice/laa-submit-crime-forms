module Type
  class Gbp < ActiveModel::Type::Decimal
    def cast(value)
      if suitable_for_casting?(value)
        # When a monetary value is provided by a form submission, we are only interested
        # in the value to 2 decimal places, and discard any more fine detail immediately
        super(value&.to_s&.delete(',')&.delete('£'))&.round(2)
      else
        # If the user has entered a string that is not straightforwardly parseable
        # as an integer, retain the original value so we can display it back to the user
        value
      end
    end

    def suitable_for_casting?(value)
      value.is_a?(Numeric) || value.blank? || value.strip.gsub(/[0-9,.£-]/, '').empty?
    end
  end
end
