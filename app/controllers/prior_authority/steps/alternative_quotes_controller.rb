module PriorAuthority
  module Steps
    class AlternativeQuotesController < BaseController
      def edit
        @form_object = AlternativeQuotes::OverviewForm.build(
          current_application
        )
        # We never want 'yes' to be pre-selected as it makes for confusing UX.
        # 'No' being pre-selected is fine otherwise users have to re-enter the same information
        # every time they come back to this screen.
        @form_object.alternative_quotes_still_to_add = nil if @form_object.alternative_quotes_still_to_add
      end

      def update
        update_and_advance(AlternativeQuotes::OverviewForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :alternative_quotes
      end
    end
  end
end
