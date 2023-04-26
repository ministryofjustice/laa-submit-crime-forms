class AddColumnReasonForClaim < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :reason_for_claim, :string
    add_column :claims, :provide_details, :string
    add_column :claims, :core_costs_exceed_higher_limit, :bool
    add_column :claims, :enhanced_rates_claimed, :bool
    add_column :claims, :councel_or_agent_assigned, :bool
    add_column :claims, :representation_order_withdrawn_on, :bool
    add_column :claims, :extradition, :bool
    add_column :claims, :other, :bool
  end
end
