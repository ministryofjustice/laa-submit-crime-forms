module Nsm
  module Steps
    class CaseCategoryController < Nsm::Steps::BaseController
      def edit
        @form_object = CaseCategoryForm.build(
          current_application
        )
      end

      def update
        update_and_advance(CaseCategoryForm, as: :case_category)
      end
    end
  end
end
