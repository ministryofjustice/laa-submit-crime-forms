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

      def should_keep_youth_court_claimed?
        plea_category == PleaCategory::CATEGORY_1A ||
          plea_category == PleaCategory::CATEGORY_2A
      end

      private

      def persist!
        application.update!(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        {
          'include_youth_court_fee' => should_keep_youth_court_claimed? ? application.include_youth_court_fee : nil,
        }
      end
    end
  end
end
