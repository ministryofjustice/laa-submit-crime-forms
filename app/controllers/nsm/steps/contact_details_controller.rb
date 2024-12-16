module Nsm
  module Steps
    class ContactDetailsController < Nsm::Steps::BaseController
      def edit
        @form_object = ContactDetailsForm.build(
          current_application.solicitor,
          application: current_application,
        )
      end

      def update
        update_and_advance(ContactDetailsForm, as: :contact_details, record: current_application.solicitor)
      end
    end
  end
end
