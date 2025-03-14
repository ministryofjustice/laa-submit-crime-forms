module Nsm
  module Steps
    class FirmDetailsController < Nsm::Steps::BaseController
      def edit
        @form_object = FirmDetailsForm.build(
          current_application
        )
      end

      def update
        update_and_advance(FirmDetailsForm, as: :firm_details)
      end

      private

      def additional_permitted_params
        [
          firm_office_attributes: Nsm::Steps::FirmDetails::FirmOfficeForm.attribute_names,
          solicitor_attributes: Nsm::Steps::FirmDetails::SolicitorForm.attribute_names,
        ]
      end
    end
  end
end
