module FilterRowsHelper
  def filter_rows(rows, *keys)
    rows.select do |row|
      keys.include?(row[:head_key])
    end
  end
end

RSpec.configuration.include FilterRowsHelper
