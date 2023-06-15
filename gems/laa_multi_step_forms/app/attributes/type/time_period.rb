module Type
  class TimePeriod < ActiveModel::Type::Integer
    # Used to coerce a Rails multi parameter period into a integer,
    # with some light validation to ensure all fields are entered.
    # Additional validation is performed in the form object through
    # the validators.
    def cast(value)
      if value.is_a?(Hash)
        # extract hours and minutes from hash
        hours, minutes = value.values_at(1, 2)
        if valid_period?(hours, minutes)
          # convert hours and minutes into
          IntegerTimePeriod.new((hours.to_i * 60) + minutes.to_i)
        else
          # This is not a valid period, but we return the hash so we perform
          # more granular validation in the form object and can render the
          # view with the errors and whatever values the user entered.
          value
        end
      else
        # we should only get here when value is retrieved from the DB as an
        # integer. As such we don't add any additional checks at this stage
        # and would except the system to error if a non integer value is used.
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
