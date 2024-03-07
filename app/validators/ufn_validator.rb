class UfnValidator < ActiveModel::EachValidator
  attr_reader :record, :attribute

  def validate_each(record, attribute, value)
    # this will trigger a `:blank` error when `presence: true`
    return if value.blank?

    @record = record
    @attribute = attribute

    matched, *date_parts_strings = *value.match(%r{\A(\d{2})(\d{2})(\d{2})/\d{3}\z})
    date_parts = date_parts_strings.reverse.map(&:to_i)

    if matched && Date.valid_date?(*date_parts)
      # convert to 4 digit date
      date_parts[0] += 2000

      add_error :future_date if Date.new(*date_parts) > Time.zone.today
    else
      add_error :invalid
    end
  end

  private

  def add_error(error)
    record.errors.add(attribute, error)
  end
end
