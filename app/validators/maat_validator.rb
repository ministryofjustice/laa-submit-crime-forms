class MaatValidator < ActiveModel::EachValidator
  attr_reader :record, :attribute

  HARDCODED_VALUES = %w[4900900].freeze

  def validate_each(record, attribute, value)
    # this will trigger a `:blank` error when `presence: true`
    return if value.blank?

    return if HARDCODED_VALUES.include?(value) || value.match?(/\A\d{7}\z/)

    record.errors.add(attribute, :invalid)
  end
end
