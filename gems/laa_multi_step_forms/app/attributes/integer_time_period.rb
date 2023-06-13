class IntegerTimePeriod < SimpleDelegator
  def hours
    return nil if __getobj__.nil?

    __getobj__ / 60
  end

  def minutes
    return nil if __getobj__.nil?

    __getobj__ % 60
  end

  # helper method that can be checked with `.try?(:valid?)` to determine
  # is the instance was correct instantiated
  def valid?
    true
  end
end
