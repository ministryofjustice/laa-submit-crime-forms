module Nsm
  class ImportsController < ApplicationController
    include ClaimCreatable
    before_action :set_current_navigation_item

    def new
      @form_object = ImportForm.new
    end

    def create
      @form_object = ImportForm.new(params.expect(nsm_import_form: [:file_upload]))

      if @form_object.valid?
        initialize_application do |claim|
          success_message = Nsm::Importers::Xml::ImportService.call(claim, @form_object)
          if success_message
            redirect_to edit_nsm_steps_claim_type_path(claim.id), flash: { success: success_message }
          else
            render :new
          end
        end
      else
        render :new
      end
    rescue ActionController::ParameterMissing
      @form_object = ImportForm.new
      @form_object.errors.add(:file_upload, :blank)
      render :new
    end

    def self.model_class
      Claim
    end

    private

    def set_current_navigation_item
      @current_navigation_item = :search
    end
  end
end
