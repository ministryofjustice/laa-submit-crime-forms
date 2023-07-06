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
      disbursement_cost: :disbursements,
    }.freeze

    SHOW_MAPPING = {
      other_info: :start_page,
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

    def after_disbursement_type
      edit(:disbursement_cost, disbursement_id: form_object.record.id)
    end

    def after_defendant_summary
      add_another(
        scope: application.defendants,
        add_view: :defendant_details,
        sub_id: :defendant_id,
        form: Steps::DefendantDetailsForm,
        proceed_url: edit(:case_details),
      )
    end

    def after_work_items
      add_another(
        scope: application.work_items,
        add_view: :work_item,
        sub_id: :work_item_id,
        form: Steps::WorkItemForm,
        proceed_url: edit(:letters_calls),
      )
    end

    def after_disbursements
      add_another(
        scope: application.disbursements,
        add_view: :disbursement_type,
        sub_id: :disbursement_id,
        form: [Steps::DisbursementTypeForm, Steps::DisbursementCostForm],
        proceed_url: show(:cost_summary),
      )
    end

    def after_firm_details
      create_new_or_summary(
        page: :defendant_details,
        summary_page: :defendant_summary,
        nested_id: :defendant_id,
        scope: application.defendants,
      )
    end

    def after_claim_details
      create_new_or_summary(
        page: :work_item,
        summary_page: :work_items,
        nested_id: :work_item_id,
        scope: application.work_items,
      )
    end

    def after_work_item_delete
      create_new_or_summary(
        page: :work_item,
        summary_page: :work_items,
        nested_id: :work_item_id,
        scope: application.work_items,
      )
    end

    def after_disbursement_delete
      create_new_or_summary(
        page: :disbursement_type,
        summary_page: :disbursements,
        nested_id: :disbursement_id,
        scope: application.disbursements,
      )
    end

    def after_letters_calls
      create_new_or_summary(
        page: :disbursement_type,
        summary_page: :disbursements,
        nested_id: :disbursement_id,
        options: { edit_when_one: true },
        scope: application.disbursements
      )
    end

    def add_another(scope:, add_view:, sub_id:, form:, proceed_url:)
      if form_object.add_another.yes?
        edit(add_view, sub_id => StartPage::NEW_RECORD)
      else
        # we direct the user to any invalid forms when they choose next
        forms = Array(form)
        invalid_instance = scope.detect { |record| forms.any? { |f| !f.build(record, application:).valid? } }
        if invalid_instance
          edit(add_view, sub_id => invalid_instance.id, :flash => { error: 'Can not continue until valid!' })
        else
          proceed_url
        end
      end
    end

    def create_new_or_summary(page:, summary_page:, nested_id:, scope:, options: { edit_when_one: false })
      count = scope.count
      if count.zero?
        edit(page, nested_id => StartPage::NEW_RECORD)
      elsif count == 1 && options[:edit_when_one]
        new_work_item = scope.first
        edit(page, nested_id => new_work_item.id)
      else
        edit(summary_page)
      end
    end
  end
end
