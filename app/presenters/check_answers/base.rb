module CheckAnswers
  class Base
    def translate_table_key(table, key, **opt)
      I18n.t("steps.check_answers.show.sections.#{table}.#{key}.key", **opt)
    end

    def rows
      []
    end

    def capitalize_sym(obj)
      obj&.value.to_s.capitalize
    end

    def get_value_obj_desc(value_object, key)
      value_object.all.find { |value| value.id == key }&.description
    end
  end
end
