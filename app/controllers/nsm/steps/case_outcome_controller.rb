module Nsm
  module Steps
    class CaseOutcomeController < BaseController
      before_action :set_case_outcomes

      def edit
        @form_object = CaseOutcomeForm.build(
          current_application
        )
      end

      def update
        update_and_advance(CaseOutcomeForm, as: :case_outcome)
      end

      def set_case_outcomes
        @case_outcomes =
          case current_application.plea_category
          when /\Acategory_1[ab]\z/ then CaseOutcome::CATEGORY_1_OUTCOMES
          when /\Acategory_2[ab]?\z/ then CaseOutcome::CATEGORY_2_OUTCOMES
          else
            raise "Invalid plea category: '#{current_application.plea_category}'"
          end
      end
    end
  end
end
