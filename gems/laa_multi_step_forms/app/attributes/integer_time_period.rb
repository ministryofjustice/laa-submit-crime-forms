class IntegerTimePeriod < SimpleDelegator
  delegate :nil?, to: :__getobj__

  def hours
    return nil if __getobj__.nil?

    __getobj__ / 60
  end

  def minutes
    return nil if __getobj__.nil?

    __getobj__ % 60
  end

  def to_s
    hour_text = if hours == 1
                  I18n.t('helpers.time_period.hours.one', count: hours)
                else
                  I18n.t('helpers.time_period.hours.other', count: hours)
                end

    minute_text = if minutes == 1
                    I18n.t('helpers.time_period.minutes.one', count: minutes)
                  else
                    I18n.t('helpers.time_period.minutes.other', count: minutes)
                  end

    hour_text + minute_text
  end
end
