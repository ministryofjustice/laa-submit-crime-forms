module CheckAnswers
  class OtherInfoCard
    attr_reader :other_info_form

    def initialize(claim)
      @other_info_form = Steps::OtherInfoForm.build(claim)
    end

    def route_path
      'other_info'
    end

    def title
      I18n.t('steps.check_answers.groups.about_claim.other_info.title')
    end
  end
end
