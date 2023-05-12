class StartPageTaskList < TaskList::Collection
  SECTIONS = [
    [:about_you, [:firm_details]],
    [:case, [:case_details, :case_disposal, :hearing_details]],
    [:defendant, [:defendant_details, :claim_reason]],
    [:claim,
     [:claim_justification, :claim_details, :work_items, :letters_calls, :disbursements, :claim_summary,
      :additional_info]],
    [:evidence, [:upload_evidence]],
    [:review, [:check_answers]]
  ].freeze
end
