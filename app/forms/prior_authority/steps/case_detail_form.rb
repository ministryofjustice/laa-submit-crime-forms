module PriorAuthority
  module Steps
    class CaseDetailForm < ::Steps::BaseFormObject
      attribute :main_offence, :string
      attribute :rep_order_date, :multiparam_date
      attribute :client_maat_number, :string
      attribute :client_detained, :boolean
      attribute :client_detained_prison, :string
      attribute :subject_to_poca, :boolean

      validates :main_offence, presence: true
      validates :rep_order_date, presence: true, multiparam_date: { allow_past: true, allow_future: false }
      validates :client_maat_number, presence: true
      validates :client_detained, inclusion: { in: [true, false] }
      validates :client_detained_prison, presence: true, if: :client_detained
      validates :subject_to_poca, inclusion: { in: [true, false] }

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
