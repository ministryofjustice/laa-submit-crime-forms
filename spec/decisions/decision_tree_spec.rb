require 'rails_helper'

RSpec.describe Decisions::DecisionTree do
  let(:id) { SecureRandom.uuid }
  let(:application) { build(:claim, id:) }
  let(:record) { application }
  let(:form) { double(:form, application:, record:) }

  it_behaves_like 'a generic decision', from: :claim_type, goto: { action: :show, controller: :start_page }

  context 'no existing defendants' do
    it_behaves_like 'a generic decision', from: :firm_details, goto: { action: :edit, controller: :defendant_details, defendant_id: StartPage::NEW_RECORD }
  end

  context 'existing invalid defendants' do
    let(:defendant_id) { SecureRandom.uuid }
    let(:application) { build(:claim, defendants: [build(:defendant, id: defendant_id)]) }

    it_behaves_like 'a generic decision', from: :firm_details, goto: { action: :edit, controller: :defendant_details }, additional_param: :defendant_id
  end

  context 'existing valid defendants' do
    let(:application) { build(:claim, defendants: [build(:defendant, :valid)]) }

    it_behaves_like 'a generic decision', from: :firm_details, goto: { action: :edit, controller: :defendant_summary }
  end

  it_behaves_like 'a generic decision', from: :defendant_details, goto: { action: :edit, controller: :defendant_summary }
  it_behaves_like 'a generic decision', from: :defendant_delete, goto: { action: :edit, controller: :defendant_summary }

  context 'answer yes to add_another for defendants' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::YES) }

    it_behaves_like 'a generic decision', from: :defendant_summary, goto: { action: :edit, controller: :defendant_details, defendant_id: StartPage::NEW_RECORD }
  end

  context 'answer no to add_another for defendants' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::NO) }

    context 'existing invalid defendant' do
      let(:application) { build(:claim, defendants: [build(:defendant)]) }

      it_behaves_like 'a generic decision', from: :defendant_summary, goto: { action: :edit, controller: :defendant_summary }
    end

    it_behaves_like 'a generic decision', from: :defendant_summary, goto: { action: :edit, controller: :case_details }
  end

  it_behaves_like 'a generic decision', from: :case_details, goto: { action: :edit, controller: :hearing_details }
  it_behaves_like 'a generic decision', from: :hearing_details, goto: { action: :edit, controller: :case_disposal }
  it_behaves_like 'a generic decision', from: :case_disposal, goto: { action: :edit, controller: :reason_for_claim }
  it_behaves_like 'a generic decision', from: :reason_for_claim, goto: { action: :edit, controller: :claim_details }

  context 'no existing work_items' do
    it_behaves_like 'a generic decision', from: :claim_details, goto: { action: :edit, controller: :work_item, work_item_id: StartPage::NEW_RECORD }
  end

  context 'existing invalid work_items' do
    let(:work_item_id) { SecureRandom.uuid }
    let(:application) { build(:claim, work_items: [build(:work_item, id: work_item_id)]) }

    it_behaves_like 'a generic decision', from: :claim_details, goto: { action: :edit, controller: :work_item }, additional_param: :work_item_id
  end

  context 'existing valid work_items' do
    let(:application) { build(:claim, work_items: [build(:work_item, :valid)]) }

    it_behaves_like 'a generic decision', from: :claim_details, goto: { action: :edit, controller: :work_items }
  end

  it_behaves_like 'a generic decision', from: :work_item, goto: { action: :edit, controller: :work_items }

  context 'when no work items' do
    it_behaves_like 'a generic decision', from: :work_item_delete, goto: { action: :edit, controller: :work_item, work_item_id: StartPage::NEW_RECORD }
  end

  context 'when work items' do
    let(:application) { build(:claim, work_items: [build(:work_item, :valid)]) }

    it_behaves_like 'a generic decision', from: :work_item_delete, goto: { action: :edit, controller: :work_items }
  end

  context 'answer yes to add_another for work_items' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::YES) }

    it_behaves_like 'a generic decision', from: :work_items, goto: { action: :edit, controller: :work_item, work_item_id: StartPage::NEW_RECORD }
  end

  context 'answer no to add_another for work_items' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::NO) }

    context 'existing invalid work_items' do
      let(:application) { build(:claim, work_items: [build(:work_item)]) }

      it_behaves_like 'a generic decision', from: :work_items, goto: { action: :edit, controller: :work_items }
    end

    it_behaves_like 'a generic decision', from: :work_items, goto: { action: :edit, controller: :letters_calls }
  end

  context 'no existing disbursements' do
    it_behaves_like 'a generic decision', from: :letters_calls, goto: { action: :edit, controller: :disbursement_type, disbursement_id: StartPage::NEW_RECORD }
  end

  context 'existing invalid disbursements (type)' do
    let(:disbursement_id) { SecureRandom.uuid }
    let(:application) { build(:claim, disbursements: [build(:disbursement, id: disbursement_id)]) }

    it_behaves_like 'a generic decision', from: :letters_calls, goto: { action: :edit, controller: :disbursement_type }, additional_param: :disbursement_id
  end

  context 'existing invalid disbursements (cost)' do
    let(:disbursement_id) { SecureRandom.uuid }
    let(:application) { build(:claim, disbursements: [build(:disbursement, :valid_type, id: disbursement_id)]) }

    it_behaves_like 'a generic decision', from: :letters_calls, goto: { action: :edit, controller: :disbursement_cost }, additional_param: :disbursement_id
  end

  context 'existing valid disbursements' do
    let(:application) { build(:claim, disbursements: [build(:disbursement, :valid)]) }

    it_behaves_like 'a generic decision', from: :letters_calls, goto: { action: :edit, controller: :disbursements }
  end

  context 'with a disbursement record' do
    let(:disbursement_id) { SecureRandom.uuid }
    let(:record) { double(:record, id: disbursement_id) }

    it_behaves_like 'a generic decision', from: :disbursement_type, goto: { action: :edit, controller: :disbursement_cost }, additional_param: :disbursement_id
  end

  it_behaves_like 'a generic decision', from: :disbursement_cost, goto: { action: :edit, controller: :disbursements }

  context 'when no disbursements' do
    it_behaves_like 'a generic decision', from: :disbursement_delete, goto: { action: :edit, controller: :disbursement_type, disbursement_id: StartPage::NEW_RECORD }
  end

  context 'when disbursements' do
    let(:application) { build(:claim, disbursements: [build(:disbursement, :valid)]) }

    it_behaves_like 'a generic decision', from: :disbursement_delete, goto: { action: :edit, controller: :disbursements }
  end

  context 'answer yes to add_another for disbursements' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::YES) }

    it_behaves_like 'a generic decision', from: :disbursements, goto: { action: :edit, controller: :disbursement_type, disbursement_id: StartPage::NEW_RECORD }
  end

  context 'answer no to add_another for disbursements' do
    before { allow(form).to receive(:add_another).and_return(YesNoAnswer::NO) }

    context 'existing invalid disbursement (type)' do
      let(:application) { build(:claim, disbursements: [build(:disbursement)]) }

      it_behaves_like 'a generic decision', from: :disbursements, goto: { action: :edit, controller: :disbursements }
    end

    context 'existing invalid disbursement (cost)' do
      let(:application) { build(:claim, disbursements: [build(:disbursement, :valid_type)]) }

      it_behaves_like 'a generic decision', from: :disbursements, goto: { action: :edit, controller: :disbursements }
    end

    it_behaves_like 'a generic decision', from: :disbursements, goto: { action: :show, controller: :cost_summary }
  end

  it_behaves_like 'a generic decision', from: :other_info, goto: { action: :show, controller: :check_answers }

  context 'answer yes to answer_equality' do
    before { allow(form).to receive(:answer_equality).and_return(YesNoAnswer::YES) }

    it_behaves_like 'a generic decision', from: :equality, goto: { action: :edit, controller: :equality_questions }
  end

  context 'answer no to answer_equality' do
    before { allow(form).to receive(:answer_equality).and_return(YesNoAnswer::NO) }

    it_behaves_like 'a generic decision', from: :equality, goto: { action: :edit, controller: :solicitor_declaration }
  end

  it_behaves_like 'a generic decision', from: :equality_questions, goto: { action: :edit, controller: :solicitor_declaration }
  it_behaves_like 'a generic decision', from: :solicitor_declaration, goto: { action: :show, controller: :claim_confirmation }
end
