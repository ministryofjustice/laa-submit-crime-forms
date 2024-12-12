module Nsm
  module Steps
    class CourtAreaController < Nsm::Steps::BaseController
      def edit
        @form_object = CourtAreaForm.build(
          current_application
        )
      end

      def update
        update_and_advance(CourtAreaForm, as: :court_area)
      end
    end
  end
end
