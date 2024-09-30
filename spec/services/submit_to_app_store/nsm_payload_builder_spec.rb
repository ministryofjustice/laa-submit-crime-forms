require 'rails_helper'

RSpec.describe SubmitToAppStore::NsmPayloadBuilder do
  subject { described_class.new(claim:, scorer:) }

  let(:scorer) { double(:risk_assessment_scorer, calculate: 'high') }
  let(:assessment_comment) { 'this is an assessment' }
  let(:claim) { create(:claim, :complete, :case_type_magistrates, assessment_comment:) }
  let(:defendant) { claim.defendants.first }
  let(:disbursement) { claim.disbursements.first }
  let(:work_item) { claim.work_items.first }
  let(:pricing) { Pricing.for(claim) }

  it 'generates and send the data message for a claim' do
    travel_to(Time.zone.local(2023, 8, 17, 12, 13, 14)) do
      check_json(subject.payload).matches(
        application: {
          'assessment_comment' => 'this is an assessment',
          'agent_instructed' => 'no',
          'adjusted_total' => nil,
          'adjusted_total_inc_vat' => nil,
          'answer_equality' => 'yes',
          'arrest_warrant_date' => nil,
          'assigned_counsel' => 'no',
          'claim_type' => 'non_standard_magistrate',
          'cntp_date' => nil,
          'cntp_order' => nil,
          'concluded' => 'no',
          'conclusion' => nil,
          'cost_summary' => {
            'disbursements' => {
              gross_cost: an_instance_of(BigDecimal),
              net_cost: an_instance_of(BigDecimal),
              vat: an_instance_of(BigDecimal)
            },
            'profit_costs' => {
              gross_cost: an_instance_of(BigDecimal),
              net_cost: an_instance_of(BigDecimal),
              vat: an_instance_of(BigDecimal)
            },
            'travel' => {
              gross_cost: an_instance_of(BigDecimal),
              net_cost: an_instance_of(BigDecimal),
              vat: an_instance_of(BigDecimal)
            },
            'waiting' => {
              gross_cost: an_instance_of(BigDecimal),
              net_cost: an_instance_of(BigDecimal),
              vat: an_instance_of(BigDecimal)
            },
          },
          'court' => 'A Court',
          'court_in_undesignated_area' => nil,
          'cracked_trial_date' => nil,
          'created_at' => '2023-08-17T12:13:14.000Z',
          'defence_statement' => 10,
          'defendants' => [{
            'first_name' => an_instance_of(String),
            'last_name' => an_instance_of(String),
            'id' => defendant.id,
            'maat' => '1234567',
            'main' => true,
            'position' => 1
          }],
          'disability' => 'n',
          'disbursements' =>
          [{
            'apply_vat' => 'true',
            'details' => 'Details',
            'disbursement_date' => /\A\d{4}-\d{2}-\d{2}\z/,
            'disbursement_type' => disbursement.disbursement_type,
            'id' => disbursement.id,
            'miles' => disbursement.miles.to_s,
            'other_type' => nil,
            'position' => an_instance_of(Integer),
            'pricing' => pricing[disbursement.disbursement_type],
            'prior_authority' => disbursement.prior_authority,
            'total_cost_without_vat' => disbursement.total_cost_without_vat.to_f,
            'vat_amount' => disbursement.vat_amount.to_f,
            'vat_rate' => 0.2
          }],
          'ethnic_group' => '01_white_british',
          'firm_office' => {
            'account_number' => '1A123B',
            'address_line_1' => '2 Laywer Suite',
            'address_line_2' => 'Unit B',
            'name' => 'Firm A',
            'postcode' => 'CR0 1RE',
            'previous_id' => nil,
            'town' => 'Lawyer Town',
            'vat_registered' => 'no'
          },
          'first_hearing_date' => /\A\d{4}-\d{2}-\d{2}\z/,
          'gender' => 'm',
          'has_disbursements' => nil,
          'hearing_outcome' => /\ACP\d{2}\z/,
          'id' => claim.id,
          'is_other_info' => 'no',
          'laa_reference' => 'LAA-n4AohV',
          'letters_and_calls' => [
            { 'count' => 2, 'pricing' => 4.09, 'type' => 'letters', 'uplift' => nil },
            { 'count' => 3, 'pricing' => 4.09, 'type' => 'calls', 'uplift' => nil }
          ],
          'main_offence' => claim.main_offence,
          'main_offence_date' => /\A\d{4}-\d{2}-\d{2}\z/,
          'matter_type' => '1',
          'number_of_hearing' => 1,
          'number_of_witnesses' => 2,
          'office_code' => '1A123B',
          'office_in_undesignated_area' => false,
          'other_info' => nil,
          'plea' => claim.plea,
          'plea_category' => claim.plea_category,
          'preparation_time' => 'yes',
          'prosecution_evidence' => 1,
          'reason_for_claim_other_details' => nil,
          'reasons_for_claim' => ['enhanced_rates_claimed'],
          'remitted_to_magistrate' => 'no',
          'remitted_to_magistrate_date' => nil,
          'rep_order_date' => /\A\d{4}-\d{2}-\d{2}\z/,
          'representation_order_withdrawn_date' => nil,
          'send_by_post' => nil,
          'signatory_name' => an_instance_of(String),
          'solicitor' => {
            'contact_email' => 'james@email.com',
            'contact_first_name' => 'James',
            'contact_last_name' => 'Blake',
            'first_name' => 'Richard',
            'last_name' => 'Jenkins',
            'previous_id' => nil,
            'reference_number' => '111222'
          },
          'stage_reached' => :prom,
          'status' => 'draft',
          'submitted_total' => nil,
          'submitted_total_inc_vat' => nil,
          'submitter' => { 'description' => nil, 'email' => 'provider@example.com' },
          'supplemental_claim' => 'yes',
          'wasted_costs' => 'yes',
          'time_spent' => 121,
          'transferred_to_undesignated_area' => nil,
          'ufn' => '120423/001',
          'unassigned_counsel' => 'no',
          'updated_at' => '2023-08-17T12:13:14.000Z',
          'vat_rate' => 0.2,
          'work_after' => 'yes',
          'work_after_date' => '2020-01-01',
          'work_completed_date' => '2020-01-02',
          'work_before' => 'yes',
          'work_before_date' => '2020-12-01',
          'work_items' =>
          [{
            'completed_on' => /\A\d{4}-\d{2}-\d{2}\z/,
            'fee_earner' => an_instance_of(String),
            'id' => work_item.id,
            'position' => 1,
            'pricing' => pricing[work_item.work_type],
            'time_spent' => an_instance_of(Integer),
            'uplift' => nil,
            'work_type' => work_item.work_type,
          }],
          'youth_court' => 'no',
          'supporting_evidences' =>
            [{
              'document_type' => 'supporting_evidence',
              'documentable_id' => an_instance_of(String),
              'documentable_type' => 'Claim',
              'created_at' => '2023-08-17T12:13:14.000Z',
               'file_name' => 'test.png',
               'file_path' => 'test_path',
               'file_size' => 1234,
               'file_type' => 'image/png',
               'id' => an_instance_of(String),
               'updated_at' => '2023-08-17T12:13:14.000Z'
            }],
            'work_item_pricing' => {
              'advocacy' => 65.42,
              'attendance_with_counsel' => 35.68,
              'attendance_without_counsel' => 52.15,
              'preparation' => 52.15
            },
        },
        application_id: claim.id,
        application_state: 'submitted',
        application_risk: 'high',
        json_schema_version: 1,
        application_type: 'crm7'
      )
    end
  end
end
