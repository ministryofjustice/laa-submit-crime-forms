module CheckAnswers
  class DefendantDetailsCard
    attr_reader :defendant_details_form

    def initialize(claim)
      # @defendant_details_form = Steps::DefendantDetailsForm.build(claim)
    end

    def route_path
      'defendant_summary'
    end

    def title
      I18n.t('steps.check_answers.groups.about_defendant.defendant_details.title')
    end
  end
end
