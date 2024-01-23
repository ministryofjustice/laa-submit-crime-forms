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
          text: "<strong class=\"govuk-tag #{I18n.t("claims.index.status_colour.#{claim.status}")}\">" \
                "#{I18n.t("claims.index.status.#{claim.status}")}</strong>".html_safe
        },
        date_actioned_row
      ].compact
    end

    private

    def date_actioned_row
      {
        head_key: date_actioned_head,
        text: claim.updated_at&.strftime('%d %B %Y')
      }
    end

    def date_actioned_head
      case claim.status
      when 'submitted'
        I18n.t('steps.check_answers.show.sections.application_status.submitted')
      when 'granted'
        I18n.t('steps.check_answers.show.sections.application_status.granted')
      when 'part_grant'
        I18n.t('steps.check_answers.show.sections.application_status.part_granted')
      else
        I18n.t('steps.check_answers.show.sections.application_status.returned')
      end
    end
  end
end
