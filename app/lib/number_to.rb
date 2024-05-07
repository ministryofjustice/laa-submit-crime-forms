module NumberTo
  extend ActionView::Helpers::NumberHelper

  def self.pounds(*values)
    value = values.any?(&:nil?) ? nil : values.sum
    return '£' unless value

    number_to_currency(value, unit: '£')
  end

  def self.percentage(value, decimals: 0, multiplier: 100)
    "#{(value * multiplier).round(decimals)}%"
  end
end
