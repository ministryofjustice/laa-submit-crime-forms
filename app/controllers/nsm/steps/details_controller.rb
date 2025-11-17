module Nsm
  module Steps
    class DetailsController < Nsm::Steps::BaseController
      def edit
        @form_object = DetailsForm.build(
          current_application
        )
      end

      def update
        params[:initialize] = true
        update_and_advance(DetailsForm, as: :details)
      end

      def current_application
        if params[:id] == StartPage::NEW_RECORD
          @current_application ||= Claim.new(initial_attributes)
        else
          super
        end
      end

      private

      def initial_attributes
        {
          'submitter' => current_provider,
          'office_code' => (current_provider.office_codes.first unless current_provider.multiple_offices?)
        }
      end
    end
  end
end
