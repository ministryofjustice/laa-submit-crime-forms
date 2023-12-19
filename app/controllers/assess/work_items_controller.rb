module Assess
  class WorkItemsController < Assess::ApplicationController
    layout nil

    def index
      claim = SubmittedClaim.find(params[:claim_id])
      work_items = BaseViewModel.build(:work_item, claim, 'work_items')
      travel_and_waiting = BaseViewModel.build(:travel_and_waiting, claim)

      render locals: { claim:, work_items:, travel_and_waiting: }
    end

    def show
      claim = SubmittedClaim.find(params[:claim_id])
      item = BaseViewModel.build(:work_item, claim, 'work_items').detect do |model|
        model.id == params[:id]
      end

      render locals: { claim:, item: }
    end

    def edit
      claim = SubmittedClaim.find(params[:claim_id])
      item = BaseViewModel.build(:work_item, claim, 'work_items').detect do |model|
        model.id == params[:id]
      end

      form = WorkItemForm.new(claim:, item:, **item.form_attributes)

      render locals: { claim:, item:, form: }
    end

    def update
      claim = SubmittedClaim.find(params[:claim_id])
      item = BaseViewModel.build(:work_item, claim, 'work_items').detect do |model|
        model.id == params[:id]
      end

      form = WorkItemForm.new(claim:, item:, **form_params)

      if form.save
        logger.debug 'saved'
        redirect_to assess_claim_adjustments_path(claim, anchor: 'work-items-tab')
      else
        render :edit, locals: { claim:, item:, form: }
      end
    end

    private

    def form_params
      params.require(:assess_work_item_form).permit(
        :uplift,
        :time_spent,
        :explanation
      ).merge(
        current_user: current_user,
        id: params[:id]
      )
    end
  end
end
