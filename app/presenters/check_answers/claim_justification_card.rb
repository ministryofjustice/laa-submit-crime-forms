# frozen_string_literal: true

module CheckAnswers
  class ClaimJustificationCard < Base
    attr_reader :reason_for_claim_form

    def initialize(claim)
      @reason_for_claim_form = Steps::ReasonForClaimForm.build(claim)
      @group = 'about_claim'
      @section = 'reason_for_claim'
    end

    def row_data
      [
        {
          head_key: 'reasons_for_claim',
          text: ApplicationController.helpers.sanitize(reasons_text, tags: %w[br])
        }
      ]
    end

    private

    def reasons_text
      reason_for_claim_form.reasons_for_claim.map do |reason|
        I18n.t("helpers.label.steps_reason_for_claim_form.reasons_for_claim_options.#{reason}")
      end.join('<br>')
    end
  end
end
