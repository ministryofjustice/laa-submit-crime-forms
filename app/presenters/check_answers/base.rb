module CheckAnswers
  class Base
    include LaaMultiStepForms::CheckMissingHelper
    include ActionView::Helpers::TagHelper

    attr_accessor :group, :section

    def translate_table_key(table, key, **)
      I18n.t("steps.check_answers.show.sections.#{table}.#{key}", **)
    end

    def title(**)
      I18n.t("steps.check_answers.groups.#{group}.#{section}.title", **)
    end

    def rows
      row_data.map do |row|
        row_content(row[:head_key], row[:text], row[:head_opts] || {}, footer: row[:footer])
      end
    end

    def as_json(*)
      row_data.each_with_object({}) do |row, hash|
        hash[row[:head_key]] = row[:text]
      end
    end

    def row_data
      []
    end

    def row_content(head_key, text, head_opts = {}, footer: false)
      heading = translate_table_key(section, head_key, **head_opts)
      # heading = translated_heading.start_with?('Translation missing:') ? head_key : translated_heading
      row = {
        key: {
          text: heading,
          classes: 'govuk-summary-list__value-width-50'
        },
        value: {
          text:
        }
      }
      row[:classes] = 'govuk-summary-list__row-double-border' if footer
      row
    end

    def get_value_obj_desc(value_object, key)
      value_object.all.find { |value| value.id == key }.description
    end

    def process_boolean_value(boolean_field:, value_field:, boolean_key:, value_key:, &value_formatter)
      [{
        head_key: boolean_key,
        text: check_missing(boolean_field.present?) do
          boolean_field.capitalize
        end
      },
       (if boolean_field == YesNoAnswer::YES.to_s
          {
            head_key: value_key,
            text: check_missing(value_field.present?, &value_formatter)
          }
        end)].compact
    end
  end
end
