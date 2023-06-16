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

  # rubocop:disable Metrics/AbcSize
  def validate_period(time_period)
    add_error(:blank_hours) if time_period.hours.nil?
    add_error(:invalid_hours) unless time_period.hours.to_i >= 0
    add_error(:blank_minutes) if time_period.minutes.nil?
    add_error(:invalid_minutes) unless time_period.minutes.to_i.between?(0, 59)

    if time_period.is_a?(IntegerTimePeriod)
      add_error(:invalid_period) unless time_period.to_i >= 0
    else
      # If, after all, we still don't have a valid date object, it means
      # there are additional errors, like June 31st, or day 29 in non-leap year.
      # We just add a generic error as it would be an overkill to set granular
      # errors for all the possible combinations.
      add_error(:invalid)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def add_error(error)
    record.errors.add(attribute, error)
  end
end
