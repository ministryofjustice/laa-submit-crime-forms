require 'rails_helper'

RSpec.describe Decisions::BackDecisionTree do
  let(:id) { SecureRandom.uuid }
  let(:application) { build(:claim, id:, defendants:, work_items:, disbursements:) }
  let(:record) { nil }
  let(:form) { double(:form, application:, record:) }
  let(:defendants) { [] }
  let(:work_items) { [] }
  let(:disbursements) { [] }

  it_behaves_like 'a generic decision', from: 'nsm/steps/start_page', goto: { action: :edit, controller: 'nsm/steps/claim_type' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/firm_details', goto: { action: :show, controller: 'nsm/steps/start_page' }

  context 'when no defendants' do
    it_behaves_like 'a generic decision', from: 'nsm/steps/defendant_details', goto: { action: :edit, controller: 'nsm/steps/firm_details' }
  end

  context 'when any defendants' do
    before { allow(application.defendants).to receive(:exists?).and_return(true) }

    it_behaves_like 'a generic decision', from: 'nsm/steps/defendant_details', goto: { action: :edit, controller: 'nsm/steps/defendant_summary' }
  end

  it_behaves_like 'a generic decision', from: 'nsm/steps/defendant_summary', goto: { action: :edit, controller: 'nsm/steps/firm_details' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/defendant_delete', goto: { action: :edit, controller: 'nsm/steps/defendant_summary' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/case_details', goto: { action: :edit, controller: 'nsm/steps/defendant_summary' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/hearing_details', goto: { action: :edit, controller: 'nsm/steps/case_details' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/case_disposal', goto: { action: :edit, controller: 'nsm/steps/hearing_details' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/reason_for_claim', goto: { action: :edit, controller: 'nsm/steps/case_disposal' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/claim_details', goto: { action: :edit, controller: 'nsm/steps/reason_for_claim' }

  context 'when no work items' do
    it_behaves_like 'a generic decision', from: 'nsm/steps/work_item', goto: { action: :edit, controller: 'nsm/steps/claim_details' }
    it_behaves_like 'a generic decision', from: 'nsm/steps/letters_calls', goto: { action: :edit, controller: 'nsm/steps/work_item', work_item_id: StartPage::NEW_RECORD }
  end

  context 'when any work items' do
    before { allow(application.work_items).to receive(:exists?).and_return(true) }

    it_behaves_like 'a generic decision', from: 'nsm/steps/work_item', goto: { action: :edit, controller: 'nsm/steps/work_items' }
    it_behaves_like 'a generic decision', from: 'nsm/steps/letters_calls', goto: { action: :edit, controller: 'nsm/steps/work_items' }
  end

  it_behaves_like 'a generic decision', from: 'nsm/steps/work_items', goto: { action: :edit, controller: 'nsm/steps/claim_details' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/work_item_delete', goto: { action: :edit, controller: 'nsm/steps/work_items' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/disbursement_add', goto: { action: :edit, controller: 'nsm/steps/letters_calls' }

  context 'when no disbursements' do
    it_behaves_like 'a generic decision', from: 'nsm/steps/disbursement_type', goto: { action: :edit, controller: 'nsm/steps/disbursement_add' }
    it_behaves_like 'a generic decision', from: 'nsm/steps/cost_summary', goto: { action: :edit, controller: 'nsm/steps/disbursement_add' }
  end

  context 'when any disbursements' do
    before { allow(application.disbursements).to receive(:exists?).and_return(true) }

    it_behaves_like 'a generic decision', from: 'nsm/steps/disbursement_type', goto: { action: :edit, controller: 'nsm/steps/disbursements' }
    it_behaves_like 'a generic decision', from: 'nsm/steps/cost_summary', goto: { action: :edit, controller: 'nsm/steps/disbursements' }
  end

  context 'when record is set' do
    let(:disbursement_id) { SecureRandom.uuid }
    let(:record) { double(id: disbursement_id) }

    it_behaves_like 'a generic decision', from: 'nsm/steps/disbursement_cost', goto: { action: :edit, controller: 'nsm/steps/disbursement_type' }, additional_param: :disbursement_id
  end

  it_behaves_like 'a generic decision', from: 'nsm/steps/disbursements', goto: { action: :edit, controller: 'nsm/steps/letters_calls' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/disbursement_delete', goto: { action: :edit, controller: 'nsm/steps/disbursements' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/other_info', goto: { action: :show, controller: 'nsm/steps/cost_summary' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/supporting_evidence', goto: { action: :edit, controller: 'nsm/steps/other_info' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/check_answers', goto: { action: :edit, controller: 'nsm/steps/supporting_evidence' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/equality', goto: { action: :show, controller: 'nsm/steps/check_answers' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/equality_questions', goto: { action: :edit, controller: 'nsm/steps/equality' }
  it_behaves_like 'a generic decision', from: 'nsm/steps/solicitor_declaration', goto: { action: :edit, controller: 'nsm/steps/equality' }
end
