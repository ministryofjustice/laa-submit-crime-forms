module CheckAnswers
  class YourDetailsCard
    attr_reader :firm_details_form

    def initialize(claim)
      @firm_details_form = Steps::FirmDetailsForm.build(claim)
    end

    def route_path
      'firm_details'
    end

    def title
      I18n.t('steps.check_answers.groups.about_you.your_details.title')
    end
  end
end
