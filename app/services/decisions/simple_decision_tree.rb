module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    EDIT_MAPPING = {
      defendant_details: :defendant_summary,
      defendant_delete: :defendant_summary,
      case_details: :case_disposal,
      case_disposal: :hearing_details,
      hearing_details: :reason_for_claim,
      reason_for_claim: :claim_details,
      claim_details: :work_item,
      work_item: :work_items,
    }.freeze

    SHOW_MAPPING = {
      other_info: :start_page,
      disbursement_type: :cost_summary,
    }.freeze

    def destination
      if respond_to?("after_#{step_name}", true)
        send("after_#{step_name}")
      elsif EDIT_MAPPING[step_name]
        edit(EDIT_MAPPING[step_name])
      elsif SHOW_MAPPING[step_name]
        show(SHOW_MAPPING[step_name])
      else
        index('/claims')
      end
    end

    private

    def after_claim_type
      show(:start_page)
    end

    def after_firm_details
      direct(
        page: :defendant_details,
        summary_page: :defendant_summary,
        nested_id: :defendant_id,
        scope: form_object.application.defendants,
        create_params: { position: 1, main: true }
      )
    end

    def after_defendant_summary
      if form_object.add_another.yes?
        next_posiiton = form_object.application.defendants.maximum(:position) + 1
        new_defendant = form_object.application.defendants.create(position: next_posiiton)
        edit(:defendant_details, defendant_id: new_defendant.id)
      else
        edit(:case_details)
      end
    end

    def after_claim_details
      direct(
        page: :work_item,
        summary_page: :work_items,
        nested_id: :work_item_id,
        scope: form_object.application.work_items,
      )
    end

    def after_work_items
      if form_object.add_another.yes?
        new_work_item = form_object.application.work_items.create
        edit(:work_item, work_item_id: new_work_item.id)
      else
        edit(:letters_calls)
      end
    end

    def after_work_item_delete
      direct(
        page: :work_item,
        summary_page: :work_items,
        nested_id: :work_item_id,
        scope: form_object.application.work_items,
      )
    end

    def after_letters_calls
      direct(
        page: :disbursement_type,
        summary_page: :start_page,
        nested_id: :disbursement_id,
        options: { edit_when_one: true },
        scope: form_object.application.disbursements
      )
    end

    def direct(page:, summary_page:, nested_id:, scope:, options: { edit_when_one: false }, create_params: {})
      count = scope.count
      if count.zero?
        new_work_item = scope.create(**create_params)
        edit(page, nested_id => new_work_item.id)
      elsif count == 1 && options[:edit_when_one]
        new_work_item = scope.first
        edit(page, nested_id => new_work_item.id)
      else
        edit(summary_page)
      end
    end

    def after_disbursement_type
      edit(:disbursement_cost, disbursement_id: form_object.record.id)
    end
  end
end
