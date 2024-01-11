module PriorAuthority
  module Steps
    class CaseContactForm < ::Steps::BaseFormObject
      attr_accessor :firm_office_attributes, :solicitor_attributes

      validates :firm_office, presence: true, nested: true
      validates :solicitor, presence: true, nested: true

      def firm_office
        @firm_office ||= PriorAuthority::Steps::CaseContact::FirmDetailForm.new(firm_office_fields.merge(application:))
      end

      def solicitor
        @solicitor ||= PriorAuthority::Steps::CaseContact::SolicitorForm.new(solicitor_fields.merge(application:))
      end

      private

      def firm_office_fields
        (firm_office_attributes || application.firm_office&.attributes || {})
          .slice(*PriorAuthority::Steps::CaseContact::FirmDetailForm.attribute_names)
      end

      def solicitor_fields
        (solicitor_attributes || application.solicitor&.attributes || {})
          .slice(*PriorAuthority::Steps::CaseContact::SolicitorForm.attribute_names)
      end

      def persist!
        firm_office.save!
        solicitor.save!
      end
    end
  end
end
