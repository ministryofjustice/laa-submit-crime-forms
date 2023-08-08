require 'rails_helper'

RSpec.describe Decisions::BackDecisionTree do
  let(:id) { SecureRandom.uuid }
  let(:application) { build(:claim, id:, defendants:, work_items:, disbursements:) }
  let(:record) { nil }
  let(:form) { double(:form, application:, record:) }
  let(:defendants) { [] }
  let(:work_items) { [] }
  let(:disbursements) { [] }

  it_behaves_like 'a generic decision', from: 'steps/firm_details', goto: { action: :show, controller: 'steps/start_page' }

  context 'when no defendants' do
    it_behaves_like 'a generic decision', from: 'steps/defendant_details', goto: { action: :edit, controller: 'steps/firm_details' }
  end

  context 'when any defendants' do
    let(:defendants) { [build(:defendant)] }

    it_behaves_like 'a generic decision', from: 'steps/defendant_details', goto: { action: :edit, controller: 'steps/defendant_summary' }
  end

  it_behaves_like 'a generic decision', from: 'steps/defendant_summary', goto: { action: :edit, controller: 'steps/firm_details' }
  it_behaves_like 'a generic decision', from: 'steps/defendant_delete', goto: { action: :edit, controller: 'steps/defendant_summary' }
  it_behaves_like 'a generic decision', from: 'steps/case_details', goto: { action: :edit, controller: 'steps/defendant_summary' }
  it_behaves_like 'a generic decision', from: 'steps/hearing_details', goto: { action: :edit, controller: 'steps/case_details' }
  it_behaves_like 'a generic decision', from: 'steps/case_disposal', goto: { action: :edit, controller: 'steps/hearing_details' }
  it_behaves_like 'a generic decision', from: 'steps/reason_for_claim', goto: { action: :edit, controller: 'steps/case_disposal' }
  it_behaves_like 'a generic decision', from: 'steps/claim_details', goto: { action: :edit, controller: 'steps/reason_for_claim' }

  context 'when no work items' do
    it_behaves_like 'a generic decision', from: 'steps/work_item', goto: { action: :edit, controller: 'steps/claim_details' }
  end

  context 'when any work items' do
    let(:work_items) { [build(:work_item)] }

    it_behaves_like 'a generic decision', from: 'steps/work_item', goto: { action: :edit, controller: 'steps/work_items' }
  end

  it_behaves_like 'a generic decision', from: 'steps/work_items', goto: { action: :edit, controller: 'steps/claim_details' }
  it_behaves_like 'a generic decision', from: 'steps/work_item_delete', goto: { action: :edit, controller: 'steps/work_items' }
  it_behaves_like 'a generic decision', from: 'steps/letters_calls', goto: { action: :edit, controller: 'steps/work_items' }
  it_behaves_like 'a generic decision', from: 'steps/disbursement_add', goto: { action: :edit, controller: 'steps/letters_calls' }

  context 'when no disbursements' do
    it_behaves_like 'a generic decision', from: 'steps/disbursement_type', goto: { action: :edit, controller: 'steps/disbursement_add' }
    it_behaves_like 'a generic decision', from: 'steps/cost_summary', goto: { action: :edit, controller: 'steps/disbursement_add' }
  end

  context 'when any disbursements' do
    let(:disbursements) { [build(:disbursement)] }

    it_behaves_like 'a generic decision', from: 'steps/disbursement_type', goto: { action: :edit, controller: 'steps/disbursements' }
    it_behaves_like 'a generic decision', from: 'steps/cost_summary', goto: { action: :edit, controller: 'steps/disbursements' }
  end

  context 'when record is set' do
    let(:disbursement_id) { SecureRandom.uuid }
    let(:record) { double(id: disbursement_id) }

    it_behaves_like 'a generic decision', from: 'steps/disbursement_cost', goto: { action: :edit, controller: 'steps/disbursement_type' }, additional_param: :disbursement_id
  end

  it_behaves_like 'a generic decision', from: 'steps/disbursements', goto: { action: :edit, controller: 'steps/letters_calls' }
  it_behaves_like 'a generic decision', from: 'steps/disbursement_delete', goto: { action: :edit, controller: 'steps/disbursements' }
  it_behaves_like 'a generic decision', from: 'steps/other_info', goto: { action: :show, controller: 'steps/cost_summary' }
  it_behaves_like 'a generic decision', from: 'steps/supporting_evidence', goto: { action: :edit, controller: 'steps/other_info' }
  it_behaves_like 'a generic decision', from: 'steps/check_answers', goto: { action: :edit, controller: 'steps/supporting_evidence' }
  it_behaves_like 'a generic decision', from: 'steps/equality', goto: { action: :show, controller: 'steps/check_answers' }
  it_behaves_like 'a generic decision', from: 'steps/equality_questions', goto: { action: :edit, controller: 'steps/equality' }
  it_behaves_like 'a generic decision', from: 'steps/solicitor_declaration', goto: { action: :edit, controller: 'steps/equality' }
end
