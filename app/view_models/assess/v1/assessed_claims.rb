module Assess
  module V1
    class AssessedClaims < Assess::BaseViewModel
      attribute :laa_reference
      attribute :defendants
      attribute :firm_office
      attribute :updated_at, :date
      attribute :state
      attribute :claim

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant ? main_defendant['full_name'] : ''
      end

      def firm_name
        firm_office['name']
      end

      def date_assessed
        { text: I18n.l(updated_at, format: '%-d %b %Y'), sort_value: updated_at.to_fs(:db) }
      end

      def case_worker_name
        event = claim.events.where(event_type: 'Event::Decision').order(created_at: :desc).first
        event ? event.primary_user.display_name : ''
      end

      def status(item)
        case item
        when 'granted'
          { colour: 'green', text: item, sort_value: 1 }
        when 'part_grant'
          { colour: 'blue', text: item, sort_value: 2 }
        when 'rejected'
          { colour: 'red', text: item, sort_value: 3 }
        else
          { colour: 'grey', text: item, sort_value: 4 }
        end
      end

      def table_fields
        [
          { laa_reference: laa_reference, claim_id: claim.id },
          firm_name,
          main_defendant_name,
          date_assessed,
          case_worker_name,
          status(state)
        ]
      end
    end
  end
end
