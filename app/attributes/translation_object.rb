class TranslationObject
  attr_reader :values

  delegate :to_s, :blank?, to: :translated

  def initialize(values)
    @values = values
  end

  def ==(other)
    other.is_a?(self.class) && other.values['value'] == values['value']
  end
  alias === ==
  alias eql? ==

  def translated
    values[I18n.locale.to_s] || value
  end

  def value
    values['value']
  end
end
