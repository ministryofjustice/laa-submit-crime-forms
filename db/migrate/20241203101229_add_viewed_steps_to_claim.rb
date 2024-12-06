class AddViewedStepsToClaim < ActiveRecord::Migration[8.0]
  def change
    add_column :claims, :viewed_steps, :jsonb, array: true, default: []
    add_column :prior_authority_applications, :viewed_steps, :jsonb, array: true, default: []

    # We only need to migrate data for submissions that might need forms filling in.
    # To make this migration not overly weighty we can ignore assessed submissions

    Claim.where.not(state: %w[granted part_grant auto_grant rejected expired]).find_each do |claim|
      claim.update!(viewed_steps: claim.navigation_stack.map { convert_stack_entry(_1) })
    end

    PriorAuthorityApplication.where.not(state: %w[granted part_grant auto_grant rejected expired]).find_each do |paa|
      paa.update!(viewed_steps: paa.navigation_stack.map { convert_stack_entry(_1) })
    end
  end

  def convert_stack_entry(stack_entry)
    # Normally the step name is the last bit, but sometimes there's a UUID there, in which case we want
    # the bit before it, and sometimes there's a query string (that could also contain a UUID), which we want to eliminate

    # e.g.
    # /prior-authority/applications/ID-WITH-DASHES/steps/prison_law -> prison_law
    # /prior-authority/applications/ID-WITH-DASHES/steps/service_cost?id=ID-WITH-DASHES -> service_cost
    # /nsm/applications/ID-WITH-DASHES/steps/work_item/ID-WITH-DASHES -> work_item
    stack_entry.split('/').reject { _1.include?('-') && !_1.include?('?') }.last.split('?').first
  end
end
