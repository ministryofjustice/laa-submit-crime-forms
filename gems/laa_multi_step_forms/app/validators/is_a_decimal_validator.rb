class IsADecimalValidator < ActiveModel::EachValidator
  # Similar functionality to IsANumberValidator but verifies for decimals
  DEFAULT_OPTIONS = {
    greater_than: 0
  }.freeze

  attr_reader :record, :attribute, :config

  def initialize(options)
    super
    @config = DEFAULT_OPTIONS.merge(options)
  end

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :not_a_decimal) if !Float(value, exception: false)
    record.errors.add(attribute, :greater_than) if value.to_f <= config[:greater_than]
  end
end
