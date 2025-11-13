module Nsm
  module Steps
    class BoiDetailsController < Nsm::Steps::BaseController
      def edit
        @form_object = BoiDetailsForm.build(
          current_application
        )
      end

      def update
        params[:initialize] = true
        update_and_advance(BoiDetailsForm, as: :boi_details)
      end

      def current_application
        if params[:id] == StartPage::NEW_RECORD
          @current_application ||= Claim.new(submitter: current_provider)
        else
          super
        end
      end
    end
  end
end
