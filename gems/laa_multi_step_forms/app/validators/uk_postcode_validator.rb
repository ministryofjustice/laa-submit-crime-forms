class UkPostcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    parsed = parse_postcode(value)

    return if parsed.full_valid? || (options[:allow_partial] && parsed.valid?)

    record.errors.add(attribute, :invalid)
  end

  private

  def parse_postcode(postcode)
    UKPostcode.parse(postcode)
  end
end
