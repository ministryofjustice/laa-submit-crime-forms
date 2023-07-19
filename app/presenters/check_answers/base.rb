module CheckAnswers
  class Base
    attr_accessor :group, :section

    def translate_table_key(table, key, **opt)
      I18n.t("steps.check_answers.show.sections.#{table}.#{key}", **opt)
    end

    def title(**opt)
      I18n.t("steps.check_answers.groups.#{group}.#{section}.title", **opt)
    end

    def rows
      row_data.map do |key, value|
        head_opts = value.key?(:head_opts) ? value[:head_opts] : {}
        row_content(key, value[:text], head_opts)
      end
    end

    def row_data
      {}
    end

    def row_content(head_key, text, head_opts)
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
