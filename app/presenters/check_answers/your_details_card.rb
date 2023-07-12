module CheckAnswers
  class YourDetailsCard
    def initialize(claim)

    end

    def route_path
      "firm_details"
    end

    def title
      I18n.t('steps.check_answers.groups.about_you.your_details.title')
    end
  end
end