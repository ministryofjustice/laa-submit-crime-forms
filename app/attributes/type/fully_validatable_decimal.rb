module Type
  class FullyValidatableDecimal < ActiveModel::Type::Decimal
    def cast(value)
      if check_valid(value)
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

    def check_valid(value)
      checks = [
        value.is_a?(Integer),
        value.is_a?(Float),
        value.blank?,
        Float(remove_commas(value), exception: false),
        Integer(remove_commas(value), exception: false)
      ]
      (checks - [nil, false]).present?
    end
  end
end
