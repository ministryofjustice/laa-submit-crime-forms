module Nsm
  module Steps
    class DetailsController < Nsm::Steps::BaseController
      def new
        @form_object = DetailsForm.new
        render :edit
      end

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
          @current_application ||= Claim.new(submitter: current_provider)
        else
          super
        end
      end
    end
  end
end
