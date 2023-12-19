module Assess
  module V1
    class ClaimSummary < Assess::BaseViewModel
      attribute :laa_reference
      attribute :defendants
      attribute :submitted_total
      attribute :adjusted_total
      attribute :claim
      attribute :send_by_post

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant ? main_defendant['full_name'] : ''
      end

      def assigned_to
        @assigned_to ||= claim.assignments.first
      end

      def assessed_on
        claim.events.where(event_type: 'Event::Decision').order(created_at: :desc).first&.created_at
      end

      def total
        if adjusted_total.present?
          NumberTo.pounds(adjusted_total)
        elsif submitted_total.present?
          NumberTo.pounds(submitted_total)
        end
      end
    end
  end
end
