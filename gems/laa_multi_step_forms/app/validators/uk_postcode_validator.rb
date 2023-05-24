class UkPostcodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :invalid) unless parsed_postcode(value).full_valid?
  end

  private

  def parsed_postcode(postcode)
    UKPostcode.parse(postcode)
  end
end
