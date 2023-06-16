class IntegerTimePeriod < SimpleDelegator
  def hours
    return nil if __getobj__.nil?

    __getobj__ / 60
  end

  def minutes
    return nil if __getobj__.nil?

    __getobj__ % 60
  end
end
