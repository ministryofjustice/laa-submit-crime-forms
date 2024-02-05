module PriorAuthority
  module Steps
    class CaseDetailForm < ::Steps::BaseFormObject
      attr_accessor :defendant_attributes

      attribute :main_offence, :string
      attribute :rep_order_date, :multiparam_date
      attribute :client_detained, :boolean
      attribute :client_detained_prison, :string
      attribute :subject_to_poca, :boolean

      validates :defendant, presence: true, nested: true
      validates :main_offence, presence: true
      validates :rep_order_date, presence: true, multiparam_date: { allow_past: true, allow_future: false }
      validates :client_detained, inclusion: { in: [true, false] }
      validates :client_detained_prison, presence: true, if: :client_detained
      validates :subject_to_poca, inclusion: { in: [true, false] }

      def defendant
        @defendant ||= PriorAuthority::Steps::CaseDetail::DefendantForm.new(defendant_fields.merge(application:))
      end

      private

      def defendant_fields
        (defendant_attributes || application.defendant&.attributes || {})
          .slice(*PriorAuthority::Steps::CaseDetail::DefendantForm.attribute_names)
      end

      def persist!
        defendant.save!
        application.update!(attributes)
      end
    end
  end
end
