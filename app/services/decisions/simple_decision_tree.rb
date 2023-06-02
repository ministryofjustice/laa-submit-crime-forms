module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    EDIT_MAPPING = {
      firm_details: :case_details,
      case_details: :case_disposal,
      case_disposal: :hearing_details,
      defendant_details: :defendant_summary,
      defendant_delete: :defendant_summary,
      reason_for_claim: :claim_details,
      claim_details: :work_item,
      work_item: :work_items,
      work_item_delete: :work_items,
    }.freeze

    SHOW_MAPPING = {
      letters_calls: :start_page,
    }.freeze

    def destination
      case
      when respond_to?("after_#{step_name}")
        send("after_#{step_name}")
      when EDIT_MAPPING[step_name]
        edit(EDIT_MAPPING[step_name])
      when SHOW_MAPPING[step_name]
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

    def after_hearing_details
      if form_object.application.defendants.any?
        edit(:defendant_summary)
      else
        edit(:defendant_details)
      end
    end

    def after_defendants
      if form_object.add_another.yes?
        next_posiiton = form_object.application.defendants.maximum(:position) + 1
        new_defendant = form_object.application.defendants.create(position: next_posiiton)
        edit(:defendant_details, defendant_id: new_defendant.id)
      else
        edit(:reason_for_claim)
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
        edit(:work_item, work_items_id: new_work_item.id)
      else
        edit(:letters_calls)
      end
    end
  end
end
