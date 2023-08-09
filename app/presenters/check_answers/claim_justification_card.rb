# frozen_string_literal: true

module CheckAnswers
  class ClaimJustificationCard < Base
    attr_reader :claim

    def initialize(claim)
      @claim = claim
      @group = 'about_claim'
      @section = 'reason_for_claim'
    end

    def row_data
      [
        {
          head_key: 'reasons_for_claim',
          text: ApplicationController.helpers.sanitize(reasons_text, tags: %w[br strong])
        }
      ] + additional_fields
    end

    private

    def reasons_text
      check_missing(claim.reasons_for_claim.present?) do
        claim.reasons_for_claim.map do |reason|
          I18n.t("helpers.label.steps_reason_for_claim_form.reasons_for_claim_options.#{reason}")
        end.join('<br>')
      end
    end

    # rubocop:disable  Metrics/AbcSize
    def additional_fields
      additional_fields = []

      if claim.reasons_for_claim&.include?(ReasonForClaim::REPRESENTATION_ORDER_WITHDRAWN.to_s)
        additional_fields << {
          head_key: 'representation_order_withdrawn_date',
          text: check_missing(claim.representation_order_withdrawn_date) do
            claim.representation_order_withdrawn_date.strftime('%d %B %Y')
          end
        }
      end

      if claim.reasons_for_claim&.include?(ReasonForClaim::OTHER.to_s)
        additional_fields << {
          head_key: 'reason_for_claim_other_details',
          text: check_missing(claim.reason_for_claim_other_details)
        }
      end

      additional_fields
    end
    # rubocop:enable Metrics/AbcSize
  end
end
