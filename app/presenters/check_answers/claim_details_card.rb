# frozen_string_literal: true

module CheckAnswers
  require 'application_controller'
  class ClaimDetailsCard < Base
    attr_reader :claim_details_form

    def initialize(claim)
      @claim_details_form = Steps::ClaimDetailsForm.build(claim)
      @group = 'about_claim'
      @section = 'claim_details'
    end

    # rubocop:disable Metrics/MethodLength
    def row_data
      [
        {
          head_key: 'prosecution_evidence',
          text: claim_details_form.prosecution_evidence
        },
        {
          head_key: 'defence_statement',
          text: claim_details_form.defence_statement
        },
        {
          head_key: 'number_of_witnesses',
          text: claim_details_form.number_of_witnesses
        },
        {
          head_key: 'supplemental_claim',
          text: capitalize_sym(claim_details_form.supplemental_claim)
        },
        {
          head_key: 'preparation_time',
          text: preparation_time
        },
        {
          head_key: 'work_before',
          text: work_before
        },
        {
          head_key: 'work_after',
          text: work_after
        },
      ]
    end

    # rubocop:enable Metrics/MethodLength
    def preparation_time
      if claim_details_form.preparation_time
        "#{capitalize_sym(claim_details_form.preparation_time)} - #{formatted_preparation_time}"
      else
        capitalize_sym(claim_details_form.preparation_time)
      end
    end

    def work_before
      if claim_details_form.work_before
        # rubocop:disable Layout/LineLength
        "#{capitalize_sym(claim_details_form.work_before)} - #{claim_details_form.work_before_date.strftime('%d %B %Y')}"
        # rubocop:enable Layout/LineLength
      else
        capitalize_sym(claim_details_form.work_before)
      end
    end

    def work_after
      if claim_details_form.work_after
        "#{capitalize_sym(claim_details_form.work_after)} - #{claim_details_form.work_after_date.strftime('%d %B %Y')}"
      else
        capitalize_sym(claim_details_form.work_after)
      end
    end

    private

    def formatted_preparation_time
      ApplicationController.helpers.format_period(claim_details_form.time_spent)
    end
  end
end
