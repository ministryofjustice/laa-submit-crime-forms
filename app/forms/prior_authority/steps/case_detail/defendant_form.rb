module PriorAuthority
  module Steps
    module CaseDetail
      class DefendantForm < ::Steps::BaseFormObject
        include LaaCrimeFormsCommon::Validators

        attribute :maat, :string
        validates :maat, presence: true, maat: true

        private

        def persist!
          defendant = application.defendant || application.build_defendant
          defendant.assign_attributes(attributes)

          application.update!(defendant:)
        end
      end
    end
  end
end
