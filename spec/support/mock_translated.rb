module MockTranslated
  def mock_translated(value, translated_value = value.titlecase)
    double(:translated, value: value, to_s: translated_value)
  end
end

RSpec.configuration.include MockTranslated
