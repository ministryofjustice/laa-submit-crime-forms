module NumericLimits
  # PostgreSQL integer max (signed 32-bit): -2,147,483,648 to 2,147,483,647
  MAX_INTEGER = 2_147_483_647

  # PostgreSQL decimal(10,2) max: 99,999,999.99
  # Using 99,999,999.99 to match precision, but ticket specified 100,000,000
  # Using slightly lower to ensure it fits within decimal(10,2) precision
  MAX_FLOAT = 99_999_999.99
end
