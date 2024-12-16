class EmailFormatValidator < ActiveModel::EachValidator
  # This validation logic is copied from
  # https://github.com/alphagov/notifications-utils/blob/main/notifications_utils/recipient_validation/email_address.py
  # Because that logic is applied by Notify, and any email that Notify thinks is invalid will be rejected
  # synchronously when we try to send an email. So we need to catch anything Notify thinks is invalid at the point
  # of entry by a user
  HOST_NAME_PATTERN = /\A(xn|[a-z0-9]+)(-?[a-z0-9]+)*\z/i
  TLD_PATTERN = /\A([a-z]{2,63}|xn--([a-z0-9]+-)*[a-z0-9]+)\z/i
  EMAIL_REGEX_PATTERN = %r{\A(?!.*\.$)(?!^\.)[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@([^.@][^@\s]+)\z}
  MAX_LENGTH = 320
  MAX_HOST_NAME_LENGTH = 253
  MIN_HOST_NAME_PARTS = 2
  MAX_HOST_PART_LENGTH = 63
  DOUBLE_DOT = '..'.freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    match = value.scan(EMAIL_REGEX_PATTERN)

    return add_error(record, attribute) if match.blank?
    return add_error(record, attribute) if value.length > MAX_LENGTH
    return add_error(record, attribute) if value.include?(DOUBLE_DOT)

    host_name = match[0][0]
    validate_host_name(record, attribute, host_name)
  end

  def validate_host_name(record, attribute, host_name)
    host_parts = host_name.split('.')

    return add_error(record, attribute) if host_name.length > MAX_HOST_NAME_LENGTH || host_parts.length < MIN_HOST_NAME_PARTS

    host_parts.each do |part|
      return add_error(record, attribute) if part.blank? || part.length > MAX_HOST_PART_LENGTH || !HOST_NAME_PATTERN.match?(part)
    end

    add_error(record, attribute) unless TLD_PATTERN.match?(host_parts.last)
  end

  def add_error(record, attribute)
    record.errors.add(attribute, :invalid)
  end
end
