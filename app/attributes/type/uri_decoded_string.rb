module Type
  class UriDecodedString < ActiveModel::Type::String
    def cast(value)
      return nil if value.nil?

      URI.decode_www_form_component(value)
    rescue ArgumentError
      # If the value cannot be decoded, return it as is to prevent 500 error
      # (e.g., if it's not a valid URI component)
      value
    end
  end
end
