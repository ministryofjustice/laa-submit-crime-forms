module PriorAuthority
  module Steps
    module CaseDetail
      class DefendantForm < ::Steps::BaseFormObject
        attribute :maat, :string
        validates :maat, presence: true

        private

        def persist!
          existing = application.defendant
          existing&.assign_attributes(attributes)

          if existing.nil?
            application.create_defendant!(attributes)
            application.save!
          else
            application.update!(defendant: existing)
          end
        end
      end
    end
  end
end
