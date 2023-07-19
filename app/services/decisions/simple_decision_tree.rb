module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    # should be a subclass of the Rule class, but allow additional methods to be added
    RULE_CLASS = CustomRule

    from(:defendant_details).goto(edit: :defendant_summary)
    from(:defendant_details).goto(edit: :defendant_summary)
    from(:defendant_delete).goto(edit: :defendant_summary)
    from(:case_details).goto(edit: :hearing_details)
    from(:hearing_details).goto(edit: :case_disposal)
    from(:case_disposal).goto(edit: :reason_for_claim)
    from(:reason_for_claim).goto(edit: :claim_details)
    from(:claim_details).goto(edit: :work_item)
    from(:work_item).goto(edit: :work_items)
    from(:disbursement_cost).goto(edit: :disbursements)
    from(:other_info).goto(edit: :equality)
    from(:claim_type).goto(show: :start_page)
    from(:solicitor_declaration).goto(show: :claim_confirmation)

    from(:disbursement_cost)
      .goto(edit: :disbursement_type, disbursement_type_id: -> { record.id })
    from(:eqaulity)
      .when(-> { answer_equality.yes? }).goto(edit: :equality_answers)
      .goto(edit: :solicitor_declaration)
    from(:defendant_summary)
      .when(-> { add_another.yes? }).goto(edit: :defendant_details, defendant_id: StartPage::NEW_RECORD)
      .when(-> { first_invalid(application.defendants, Steps::DefendantDetailsForm) }).goto(:defendant_details, defendant_id: ->(response) { response.id })
      .goto(idit: :case_details)

    class < self do
      def rules
        @rules ||= Hash.new { |k, h| h[k] = [] }
      end

      def from(source)
        rules[source] << RULE_CLASS.new(from: source)
      end
    end

    class Rule
      def when(condition)
        @condition = condition
      end

      def to(**destination)
        @destinations ||= []
        @destinations << [@condition, destination]
        @condition = nil
      end
    end

    class CustomRule < Rule
      def first_invalid?(scope, *forms)
        scope.detect { |record| forms.any? { |f| !f.build(record, application:).valid? } }
      end
    end

    def destination
      rule = self.class.rules[step_name]
      detected, destination = rule.detect do |condition, _|
        condition.nil? || form_object.instance_eval(&condition)
      end

      destination.each_with_object({}) do |(key, value), hash|
        hash[key] =
          if value.responds_to(:call)
            value.arity.zero ? form_object.instance_eval(&value) : value.call(detected)
          else
            value
          end
      end
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

    private


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
