# rubocop:disable Metrics/ClassLength
module GOVUKDesignSystemFormBuilder
  module Elements
    class Period < ::GOVUKDesignSystemFormBuilder::Base
      using PrefixableArray

      include Traits::Error
      include Traits::Hint
      include Traits::Supplemental
      include Traits::HTMLClasses

      FIELDS = %i[hours minutes].freeze
      DEFAULT_WIDTH = 2

      def segement_id(key)
        "#{FIELDS.index(key) + 1}i"
      end

      def multiparameter_key(key)
        FIELDS.index(key) + 1
      end

      # rubocop:disable Metrics/ParameterLists
      def initialize(builder, object_name, attribute_name, legend:, caption:, hint:, maxlength_enabled:, form_group:,
                     widths: {}, **kwargs, &block)
        super(builder, object_name, attribute_name, &block)

        @legend            = legend
        @caption           = caption
        @hint              = hint
        @maxlength_enabled = maxlength_enabled
        @form_group        = form_group
        @widths            = widths
        @html_attributes   = kwargs
      end
      # rubocop:enable Metrics/ParameterLists

      def html
        Containers::FormGroup.new(*bound, **@form_group, **@html_attributes).html do
          Containers::Fieldset.new(*bound, **fieldset_options).html do
            safe_join([supplemental_content, hint_element, error_element, period])
          end
        end
      end

      private

      def fieldset_options
        { legend: @legend, caption: @caption, described_by: [error_id, hint_id, supplemental_id] }
      end

      def period
        tag.div(class: %(#{brand}-period-input)) do
          safe_join(
            FIELDS.map.with_index do |field, i|
              period_part(field, width: @widths.fetch(field, DEFAULT_WIDTH), link_errors: i.zero?)
            end
          )
        end
      end

      def maxlength_enabled?
        @maxlength_enabled
      end

      def period_part(segment, width:, link_errors: false)
        tag.div(class: %(#{brand}-period-input__item)) do
          tag.div(class: %(#{brand}-form-group)) do
            safe_join([label(segment, link_errors), input(segment, link_errors, width, value(segment))])
          end
        end
      end

      # rubocop:disable Metrics/MethodLength
      def value(segment)
        attribute = @builder.object.try(@attribute_name)

        return unless attribute

        if attribute.respond_to?(segment)
          attribute.send(segment)
        elsif attribute.respond_to?(:fetch)
          attribute.fetch(multiparameter_key(segment)) do
            warn("No key '#{segment}' found in MULTIPARAMETER_KEY hash.")

            nil
          end
        else
          raise(ArgumentError,
                'invalid TimePeriod-like object: must be a Time Period or Hash in MULTIPARAMETER_KEY format')
        end
      end
      # rubocop:enable Metrics/MethodLength

      def label(segment, link_errors)
        tag.label(
          segment.capitalize,
          class: label_classes,
          for: id(segment, link_errors)
        )
      end

      def input(segment, link_errors, width, value)
        tag.input(
          id: id(segment, link_errors),
          class: classes(width),
          name: name(segment),
          type: 'text',
          inputmode: 'numeric',
          value: value,
          maxlength: (width if maxlength_enabled?),
        )
      end

      def classes(width)
        build_classes(
          %(input),
          %(period-input__input),
          %(input--width-#{width}),
          %(input--error) => has_errors?,
        ).prefix(brand)
      end

      # if the field has errors we want the govuk_error_summary to
      # be able to link to the day field. Otherwise, generate IDs
      # in the normal fashion
      def id(segment, link_errors)
        if has_errors? && link_errors
          field_id(link_errors:)
        else
          [@object_name, @attribute_name, segement_id(segment)].join('_')
        end
      end

      def name(segment)
        format(
          '%<object_name>s[%<input_name>s(%<segment>s)]',
          object_name: @object_name,
          input_name: @attribute_name,
          segment: segement_id(segment)
        )
      end

      def label_classes
        build_classes(%(label), %(period-input__label)).prefix(brand)
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
