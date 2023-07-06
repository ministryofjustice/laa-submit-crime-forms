module StartPage
  # This allows us to use the edit and update paths before the
  # associated record is fully saved.
  NEW_RECORD = '00000000-0000-0000-0000-000000000000'.freeze

  class PreTaskList < TaskList::Collection
    SECTIONS = [[:what, [->(app) { "claim_type.#{app.claim_type}" }]]].freeze
  end

  class TaskList < TaskList::Collection
    SECTIONS = [
      [:about_you, [:firm_details]],
      [:defendant, [:defendants,]],
      [:case, [:case_details, :case_disposal, :hearing_details]],
      [:claim,
       [:reason_for_claim, :claim_details, :work_items, :letters_calls, :disbursements, :cost_summary,
        :additional_info]],
      [:evidence, [:upload_evidence]],
      [:review,
       [:check_answers, :declaration]],
    ].freeze
  end
end
