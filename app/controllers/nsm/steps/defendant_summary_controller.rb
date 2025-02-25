module Nsm
  module Steps
    class DefendantSummaryController < Nsm::Steps::BaseController
      include IncompleteItemsConcern

      def edit
        @items_incomplete_flash = build_items_incomplete_flash
        @form_object = DefendantSummaryForm.build(
          current_application
        )
      end

      def update
        update_and_advance(DefendantSummaryForm, as: :defendant_summary)
      end

      private

      def item_type
        :defendants
      end

      def additional_permitted_params
        [:add_another]
      end
    end
  end
end
