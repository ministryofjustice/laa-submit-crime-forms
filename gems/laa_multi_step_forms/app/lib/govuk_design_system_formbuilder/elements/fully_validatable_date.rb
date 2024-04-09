module GOVUKDesignSystemFormBuilder
  module Elements
    class FullyValidatableDate < ::GOVUKDesignSystemFormBuilder::Elements::Date
      # Unlike Date, this does not append an `i` to the values of SEGMENTS,
      # meaning that Rails does not automatically cast values to integers,
      # allowing for more expressive error messages if a non-numerical string
      # is entered.
      SEGMENTS = { day: '3', month: '2', year: '1' }.freeze

      def id(segment, link_errors)
        if has_errors? && link_errors
          field_id(link_errors:)
        else
          [@object_name, @attribute_name, SEGMENTS.fetch(segment)].join('_')
        end
      end

      def name(segment)
        format(
          '%<object_name>s[%<input_name>s(%<segment>s)]',
          object_name: @object_name,
          input_name: @attribute_name,
          segment: SEGMENTS.fetch(segment)
        )
      end
    end
  end
end
