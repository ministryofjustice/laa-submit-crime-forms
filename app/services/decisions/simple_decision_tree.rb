module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    def destination
      case step_name
      when :claim_type
        after_claim_type
      when :firm_details
        edit(:case_details)
      when :case_details
        edit(:case_disposal)
      when :case_disposal
        edit(:hearing_details)
      when :hearing_details, :delete_defendant
        edit(:defendant_details)
      when :defendant_details
        show(:start_page)
      when :add_defendant
        form_object.application.defendants.create(position: form_object.next_position)
        edit(:defendant_details)
      else
        index('/claims')
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    def after_claim_type
      if form_object.claim_type.supported?
        show(:start_page)
      else
        index('/claims')
      end
    end
  end
end
