# frozen_string_literal: true

module CheckAnswers
  class ApplicationStatusCard < Base
    attr_reader :claim

    def initialize(claim)
      @claim = claim
      @group = 'application_status'
      @section = 'application_status'
    end

    def row_data
      [
        {
          head_key: 'application_status',
          text: "<strong class=\"govuk-tag .status_colour.#{claim.status}\">#{I18n.t("claims.index.status.#{claim.status}")}</strong>".html_safe
        },
        date_actioned_row
      ].compact
    end

    private

    def date_actioned_row
      {
        head_key: get_date_actioned_head,
        text: claim.updated_at.strftime('%d %B %Y')
      }
    end

    def get_date_actioned_head
      case claim.status
      when 'submitted'
        I18n.t('steps.check_answers.show.sections.application_status.submitted')
      when 'granted' || 'part_granted'
        I18n.t('steps.check_answers.show.sections.application_status.assessed')
      else
        I18n.t('steps.check_answers.show.sections.application_status.returned')
      end
    end
  end
end
