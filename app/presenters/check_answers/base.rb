module CheckAnswers
  class Base
    def translate_table_key(table, key, **opt)
      I18n.t("steps.check_answers.show.sections.#{table}.#{key}.key", **opt)
    end

    def rows
      []
    end
  end
end
