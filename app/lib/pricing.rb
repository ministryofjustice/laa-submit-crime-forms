class Pricing
  class << self
    # if no date is set then we default to the current pricing rates
    def for(application)
      return new(data['pre_20220930']) if (..Date.new(2022, 9, 29)).cover?(application.date)

      new(data['post_20220930'])
    end

    # This is cached on the Class to avoid multiple file reads
    def data
      @data ||= YAML.load_file(Rails.root.join('config/pricing.yml'))
    end
  end

  FIELDS = %w[
    preparation
    advocacy
    attendance_with_counsel
    attendance_without_counsel
    travel
    waiting
    letters
    calls
  ].freeze

  attr_reader *FIELDS

  def initialize(data = {})
    FIELDS.each do |field|
      instance_variable_set("@#{field}", data.fetch(field, 0.0).to_f)
    end
  end

  def [](key)
    if FIELDS.include?(key.to_s)
      instance_variable_get("@#{key}")
    else
      0.0
    end
  end
end