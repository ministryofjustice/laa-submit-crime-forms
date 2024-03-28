# frozen_string_literal: true

module Nsm
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
            text: "<strong class=\"govuk-tag #{I18n.t("nsm.claims.index.status_colour.#{claim.status}")}\">" \
                  "#{I18n.t("nsm.claims.index.status.#{claim.status}")}</strong>".html_safe
          },
          date_actioned_row
        ].compact
      end

      private

      def date_actioned_row
        {
          head_key: date_actioned_head,
          text: claim.updated_at&.to_fs(:stamp)
        }
      end

      def date_actioned_head
        case claim.status
        when 'submitted'
          'submitted'
        when 'granted', 'auto_grant', 'part_grant'
          'assessed'
        else
          'returned'
        end
      end
    end
  end
end
