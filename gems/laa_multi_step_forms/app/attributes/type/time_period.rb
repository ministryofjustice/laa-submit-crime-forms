module Type
  class TimePeriod < ActiveModel::Type::Integer
    # Used to coerce a Rails multi parameter date into a standard date,
    # with some light validation to not end up with wrong dates or
    # raising exceptions. Additional validation is performed in the
    # form object through the validators.
    #
    def cast(value)
      if value.is_a?(Hash)
        value_args = value.values_at(1, 2)
        if valid_period?(*value_args)
          IntegerTimePeriod.new((value_args[0].to_i * 60) + value_args[1].to_i)
        else
          # This is not a valid period, but we return the hash so we perform
          # more granular validation in the form object and can render the
          # view with the errors and whatever values the user entered.
          value
        end
      else
        # when it is an integer
        IntegerTimePeriod.new(value)
      end
    end

    def serialize(value)
      value
    end

    def valid_period?(hours, minutes)
      hours.to_s =~ /\A\d+\z/ && hours.to_i >= 0 &&
        minutes.to_s =~ /\A\d+\z/ && (0..59).cover?(minutes.to_i)
    end
  end
end
