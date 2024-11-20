module Nsm
  module Steps
    class CaseCategoryForm < ::Steps::BaseFormObject
      attribute :plea_category, :value_object, source: PleaCategory

      validates :plea_category, presence: true, inclusion: { in: PleaCategory.values }

      def choices
        if application.claim_type != 'breach_of_injunction' && application.youth_court == 'yes'
          PleaCategory::WITH_YOUTH_COURT_OPTIONS
        else
          PleaCategory::WITHOUT_YOUTH_COURT_OPTIONS
        end
      end

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
