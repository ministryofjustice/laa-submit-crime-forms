module PriorAuthority
  module Steps
    module CaseDetail
      class DefendantForm < ::Steps::BaseFormObject
        attribute :maat, :string
        validates :maat, presence: true, format: /\A\d{7}\z/

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
