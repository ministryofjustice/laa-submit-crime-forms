module CheckAnswers
  class Base
    attr_accessor :group, :section

    def translate_table_key(table, key, **)
      I18n.t("steps.check_answers.show.sections.#{table}.#{key}", **)
    end

    def title(**)
      I18n.t("steps.check_answers.groups.#{group}.#{section}.title", **)
    end

    def rows
      row_data.map do |row|
        row_content(row[:head_key], row[:text], row[:head_opts] || {})
      end
    end

    def row_data
      {}
    end

    def row_content(head_key, text, head_opts = {})
      {
        key: {
          text: translate_table_key(section, head_key, **head_opts),
          classes: 'govuk-summary-list__value-width-50'
        },
        value: {
          text:
        }
      }
    end

    def route_path
      section
    end

    def capitalize_sym(obj)
      obj&.value.to_s.capitalize
    end

    def get_value_obj_desc(value_object, key)
      value_object.all.find { |value| value.id == key }&.description
    end
  end
end
