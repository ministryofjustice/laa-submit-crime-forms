require 'rails_helper'

RSpec.describe Decisions::DecisionTree do
  let(:id) { SecureRandom.uuid }
  let(:application) { build(:claim, id:) }
  let(:record) { application }
  let(:form) { double(:form, application:, record:) }

  it_behaves_like 'a generic decision', from: :claim_type, goto: { action: :show, controller: 'nsm/steps/start_page' }

  context 'no existing defendants' do
    it_behaves_like 'a generic decision', from: :firm_details, goto: { action: :edit, controller: 'nsm/steps/defendant_details', defendant_id: StartPage::NEW_RECORD }
  end

  context 'existing valid defendants' do
    let(:application) { build(:claim, defendants: [build(:defendant, :valid)]) }

    it_behaves_like 'a generic decision', from: :firm_details, goto: { action: :edit, controller: 'nsm/steps/defendant_summary' }
  end

  it_behaves_like 'a generic decision', from: :defendant_details, goto: { action: :edit, controller: 'nsm/steps/defendant_summary' }
  it_behaves_like 'a generic decision', from: :defendant_delete, goto: { action: :edit, controller: 'nsm/steps/defendant_summary' }

  context 'answer yes to add_another for defendants' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::YES) }

    it_behaves_like 'a generic decision', from: :defendant_summary, goto: { action: :edit, controller: 'nsm/steps/defendant_details', defendant_id: StartPage::NEW_RECORD }
  end

  context 'answer no to add_another for defendants' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::NO) }

    context 'existing invalid defendant' do
      let(:application) { build(:claim, defendants: [build(:defendant)]) }

      it_behaves_like 'a generic decision', from: :defendant_summary, goto: { action: :edit, controller: 'nsm/steps/defendant_summary' }
    end

    it_behaves_like 'a generic decision', from: :defendant_summary, goto: { action: :edit, controller: 'nsm/steps/case_details' }
  end

  it_behaves_like 'a generic decision', from: :case_details, goto: { action: :edit, controller: 'nsm/steps/hearing_details' }
  it_behaves_like 'a generic decision', from: :hearing_details, goto: { action: :edit, controller: 'nsm/steps/case_disposal' }
  it_behaves_like 'a generic decision', from: :case_disposal, goto: { action: :edit, controller: 'nsm/steps/reason_for_claim' }
  it_behaves_like 'a generic decision', from: :reason_for_claim, goto: { action: :edit, controller: 'nsm/steps/claim_details' }

  context 'no existing work_items' do
    it_behaves_like 'a generic decision', from: :claim_details, goto: { action: :edit, controller: 'nsm/steps/work_item', work_item_id: StartPage::NEW_RECORD }
  end

  context 'existing valid work_items' do
    let(:application) { build(:claim, work_items: [build(:work_item, :valid)]) }

    it_behaves_like 'a generic decision', from: :claim_details, goto: { action: :edit, controller: 'nsm/steps/work_items' }
  end

  it_behaves_like 'a generic decision', from: :work_item, goto: { action: :edit, controller: 'nsm/steps/work_items' }

  context 'when no work items' do
    it_behaves_like 'a generic decision', from: :work_item_delete, goto: { action: :edit, controller: 'nsm/steps/work_item', work_item_id: StartPage::NEW_RECORD }
  end

  context 'when work items' do
    let(:application) { build(:claim, work_items: [build(:work_item, :valid)]) }

    it_behaves_like 'a generic decision', from: :work_item_delete, goto: { action: :edit, controller: 'nsm/steps/work_items' }
  end

  context 'answer yes to add_another for work_items' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::YES) }

    it_behaves_like 'a generic decision', from: :work_items, goto: { action: :edit, controller: 'nsm/steps/work_item', work_item_id: StartPage::NEW_RECORD }
  end

  context 'answer no to add_another for work_items' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::NO) }

    context 'existing invalid work_items' do
      let(:application) { build(:claim, work_items: [build(:work_item)]) }

      it_behaves_like 'a generic decision', from: :work_items, goto: { action: :edit, controller: 'nsm/steps/work_items' }
    end

    it_behaves_like 'a generic decision', from: :work_items, goto: { action: :edit, controller: 'nsm/steps/letters_calls' }
  end

  context 'no existing disbursements' do
    it_behaves_like 'a generic decision', from: :letters_calls, goto: { action: :edit, controller: 'nsm/steps/disbursement_add' }
  end

  context 'existing valid disbursements' do
    let(:application) { build(:claim, disbursements: [build(:disbursement, :valid)]) }

    it_behaves_like 'a generic decision', from: :letters_calls, goto: { action: :edit, controller: 'nsm/steps/disbursements' }
  end

  context 'answer yes to has_disbursement' do
    before { allow(form).to receive(:has_disbursements).and_return(YesNoAnswer::YES) }

    it_behaves_like 'a generic decision', from: :disbursement_add, goto: { action: :edit, controller: 'nsm/steps/disbursement_type', disbursement_id: StartPage::NEW_RECORD }
  end

  context 'answer no to has_disbursement' do
    before { allow(form).to receive(:has_disbursements).and_return(YesNoAnswer::NO) }

    it_behaves_like 'a generic decision', from: :disbursement_add, goto: { action: :show, controller: 'nsm/steps/cost_summary' }
  end

  context 'with a disbursement record' do
    let(:disbursement_id) { SecureRandom.uuid }
    let(:record) { double(:record, id: disbursement_id) }

    it_behaves_like 'a generic decision', from: :disbursement_type, goto: { action: :edit, controller: 'nsm/steps/disbursement_cost' }, additional_param: :disbursement_id
  end

  it_behaves_like 'a generic decision', from: :disbursement_cost, goto: { action: :edit, controller: 'nsm/steps/disbursements' }

  context 'when no disbursements' do
    it_behaves_like 'a generic decision', from: :disbursement_delete, goto: { action: :edit, controller: 'nsm/steps/disbursement_type', disbursement_id: StartPage::NEW_RECORD }
  end

  context 'when disbursements' do
    let(:application) { build(:claim, disbursements: [build(:disbursement, :valid)]) }

    it_behaves_like 'a generic decision', from: :disbursement_delete, goto: { action: :edit, controller: 'nsm/steps/disbursements' }
  end

  context 'answer yes to add_another for disbursements' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::YES) }

    it_behaves_like 'a generic decision', from: :disbursements, goto: { action: :edit, controller: 'nsm/steps/disbursement_type', disbursement_id: StartPage::NEW_RECORD }
  end

  context 'answer no to add_another for disbursements' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::NO) }

    context 'existing invalid disbursement (type)' do
      let(:application) { build(:claim, disbursements: [build(:disbursement)]) }

      it_behaves_like 'a generic decision', from: :disbursements, goto: { action: :edit, controller: 'nsm/steps/disbursements' }
    end

    context 'existing invalid disbursement (cost)' do
      let(:application) { build(:claim, disbursements: [build(:disbursement, :valid_type)]) }

      it_behaves_like 'a generic decision', from: :disbursements, goto: { action: :edit, controller: 'nsm/steps/disbursements' }
    end

    it_behaves_like 'a generic decision', from: :disbursements, goto: { action: :show, controller: 'nsm/steps/cost_summary' }
  end

  it_behaves_like 'a generic decision', from: :other_info, goto: { action: :edit, controller: 'nsm/steps/supporting_evidence' }

  it_behaves_like 'a generic decision', from: :supporting_evidence, goto: { action: :show, controller: 'nsm/steps/check_answers' }

  context 'answer yes to answer_equality' do
    before { allow(form).to receive(:answer_equality).and_return(YesNoAnswer::YES) }

    it_behaves_like 'a generic decision', from: :equality, goto: { action: :edit, controller: 'nsm/steps/equality_questions' }
  end

  context 'answer no to answer_equality' do
    before { allow(form).to receive(:answer_equality).and_return(YesNoAnswer::NO) }

    it_behaves_like 'a generic decision', from: :equality, goto: { action: :edit, controller: 'nsm/steps/solicitor_declaration' }
  end

  it_behaves_like 'a generic decision', from: :equality_questions, goto: { action: :edit, controller: 'nsm/steps/solicitor_declaration' }
  it_behaves_like 'a generic decision', from: :solicitor_declaration, goto: { action: :show, controller: 'nsm/steps/claim_confirmation' }
end
