module Nsm
  module Steps
    class EqualityController < Nsm::Steps::BaseController
      def edit
        @form_object = AnswerEqualityForm.build(
          current_application
        )
      end

      def update
        update_and_advance(AnswerEqualityForm, as: :equality)
      end
    end
  end
end
