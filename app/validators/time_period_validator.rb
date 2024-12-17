class TimePeriodValidator < ActiveModel::EachValidator
  TIME_PERIOD_STRUCT = Struct.new('TIME_PERIOD_STRUCT', :hours, :minutes)

  attr_reader :record, :attribute

  def validate_each(record, attribute, value)
    # this will trigger a `:blank` error when `presence: true`
    return if value.blank?

    @record = record
    @attribute = attribute

    # If the value is a hash, we use a simple struct to keep a
    # consistent interface, similar to a real date object.
    # Remember, the hash will have the format: {3=>31, 2=>12, 1=>2000}
    # where `3` is the day, `2` is the month and `1` is the year.
    time_period =
      if value.is_a?(Hash)
        TIME_PERIOD_STRUCT.new(hours: value[1], minutes: value[2])
      else
        value
      end

    validate_period(time_period)
  end

  private

  def validate_period(time_period)
    validate_hours(time_period.hours)
    validate_minutes(time_period.minutes)

    if time_period.is_a?(IntegerTimePeriod)
      add_error(:zero_time_period) if time_period.to_i.zero? && !options[:allow_zero]
      add_error(:invalid_period) unless time_period.to_i >= 0
    else
      # If, after all, we still don't have a valid date object, it means
      # there are additional errors, like June 31st, or day 29 in non-leap year.
      # We just add a generic error as it would be an overkill to set granular
      # errors for all the possible combinations.
      add_error(:invalid)
    end
  end

  def validate_hours(hours)
    add_error(:blank_hours) if hours.blank?
    add_error(:non_numerical_hours) if non_numerical_string?(hours)
    add_error(:non_integer_hours) if non_integer_string?(hours)
    add_error(:invalid_hours) unless hours.to_i >= 0
  end

  def validate_minutes(minutes)
    add_error(:blank_minutes) if minutes.blank?
    add_error(:non_numerical_minutes) if non_numerical_string?(minutes)
    add_error(:non_integer_minutes) if non_integer_string?(minutes)
    add_error(:invalid_minutes) unless minutes.to_i.between?(0, 59)
  end

  def non_numerical_string?(value)
    return false unless value.is_a?(String)

    non_decimal_string?(value) && non_integer_string?(value)
  end

  def non_integer_string?(value)
    return false unless value.is_a?(String)

    value.strip.to_i.to_s != value.strip
  end

  def non_decimal_string?(value)
    value.strip.to_f.to_s != value.strip
  end

  def add_error(error)
    record.errors.add(attribute, error)
  end
end
