module PriorAuthority
  module Steps
    class AdditionalCostDetailsController < BaseController
      before_action :build_new_record, only: %i[new create]
      before_action :build_edit_record, only: %i[edit update confirm_delete destroy]

      attr_accessor :record

      def new
        build_form_object
        render :edit
      end

      def edit
        build_form_object
      end

      def create
        persist
      end

      def update
        persist
      end

      def confirm_delete
        build_form_object
      end

      def destroy
        record.destroy
        redirect_to decision_tree_class.new(build_form_object, as:).destination
      end

      private

      def build_form_object
        @form_object = AdditionalCosts::DetailForm.build(
          record,
          application: current_application
        )
      end

      def persist
        update_and_advance(AdditionalCosts::DetailForm, as:, after_commit_redirect_path:, record:)
      end

      def build_new_record
        @record = current_application.additional_costs.new
      end

      def build_edit_record
        @record = current_application.additional_costs.find(params[:id])
      end

      def as
        :additional_cost_details
      end

      def redirect_to_current_object
        redirect_to edit_prior_authority_steps_additional_cost_detail_path(current_application, record)
      end
    end
  end
end
