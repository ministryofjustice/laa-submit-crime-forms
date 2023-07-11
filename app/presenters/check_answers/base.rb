module CheckAnswers
  class Base
    def group_heading(group_key, **opt)
      I18n.t("steps.check_answers.groups.#{group_key}.heading", **opt)
    end
  end
end
