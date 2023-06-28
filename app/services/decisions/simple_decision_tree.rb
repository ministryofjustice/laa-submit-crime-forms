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
      if form_object.claim_type.supported?
        show(:start_page)
      else
        index('/claims')
      end
    end

    def after_firm_details
      if form_object.application.defendants.any?
        edit(:defendant_summary)
      else
        edit(:defendant_details)
      end
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
      if form_object.application.work_items.any?
        edit(:work_items)
      else
        edit(:work_item)
      end
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
      after_claim_details
    end

    def after_letters_calls
      if form_object.application.disbursements.any?
        edit(:disbursement_type, disbursement_id: form_object.application.disbursements.first.id)
        # edit(:disbursements)
      else
        disbursement = form_object.application.disbursements.create
        edit(:disbursement_type, disbursement_id: disbursement.id)
      end
    end
  end
end
