class YesNoAnswer < ValueObject
  RadioOption = Struct.new(:value, :label, :radio_hint)

  VALUES = [
    YES = new(:yes),
    NO  = new(:no)
  ].freeze

  def self.radio_options(radio_hints = {})
    [
      RadioOption.new(true, I18n.t('generic.yes'), radio_hints[:yes]),
      RadioOption.new(false, I18n.t('generic.no'), radio_hints[:no]),
    ]
  end
end
