require 'rails_helper'

RSpec.describe Decisions::SimpleDecisionTree do
  let(:application) { build(:claim) }

  ClaimType::SUPPORTED.each do |claim_type|
    context 'when claim_type is supported' do
      let(:form) { Steps::ClaimTypeForm.new(application:, claim_type:) }

      it_behaves_like 'a generic decision', :claim_type, :start_page, nil, action_name: :show
    end
  end

  (ClaimType::VALUES - ClaimType::SUPPORTED).each do |claim_type|
    context 'when claim_type is not supported' do
      let(:form) { Steps::ClaimTypeForm.new(application:, claim_type:) }

      context 'when step is claim_type' do
        it 'processes to the firm_details page' do
          decision_tree = described_class.new(form, as: :claim_type)
          expect(decision_tree.destination).to eq(
            action: :index,
            controller: '/claims',
          )
        end
      end
    end
  end

  it_behaves_like 'a decision with nested object',
    step_name: :firm_details, controller: :defendant_details, nested: :defendant,
    summary_controller: :defendant_summary, form_class: Steps::FirmDetailsForm,
    create_args: { main: true, position: 1 }
  it_behaves_like 'a generic decision', :defendant_details, :defendant_summary, Steps::DefendantDetailsForm
  it_behaves_like 'a generic decision', :defendant_delete, :defendant_summary, Steps::DefendantDeleteForm
  context 'when defendant exists' do
    let(:application) { create(:claim, defendants: [defendant]) }
    let(:defendant) { build(:defendant, :valid) }

    it_behaves_like 'a generic decision', :firm_details, :defendant_summary, Steps::DefendantDetailsForm
    it_behaves_like 'an add_another decision', :defendant_summary, :defendant_details, :case_details, :defendant_id,
                    additional_yes_branch_tests: lambda {
                      it 'creates a new defendant on the claim' do
                        expect { decision_tree.destination }.to change(application.defendants, :count).by(1)
                      end
                    }
  end

  it_behaves_like 'a generic decision', :case_disposal, :hearing_details, Steps::CaseDisposalForm
  it_behaves_like 'a generic decision', :hearing_details, :reason_for_claim, Steps::HearingDetailsForm
  it_behaves_like 'a generic decision', :reason_for_claim, :claim_details, Steps::ReasonForClaimForm

  it_behaves_like 'a decision with nested object',
    step_name: :claim_details, controller: :work_item,
    summary_controller: :work_items, form_class: Steps::ClaimDetailsForm
  it_behaves_like 'a generic decision', :work_item, :work_items, Steps::WorkItemForm

  context 'when work_item exists' do
    let(:application) { create(:claim, work_items: [work_item]) }
    let(:work_item) { build(:work_item, :valid) }

    it_behaves_like 'a generic decision', :work_item_delete, :work_items, Steps::DeleteForm
    it_behaves_like 'an add_another decision', :work_items, :work_item, :letters_calls, :work_item_id,
                    additional_yes_branch_tests: lambda {
                      it 'creates a new defendant on the claim' do
                        expect { decision_tree.destination }.to change(application.work_items, :count).by(1)
                      end
                    }

    context 'but is not valid' do
      let(:work_item) { build(:work_item, :partial) }

      no_controller_options = {
        name: :work_items,
        routing: Proc.new { {

          controller: :work_item,
          work_item_id: application.work_items.first.id,
          flash: { error: "Can not continue until valid!" }
        } }
      }
      it_behaves_like 'an add_another decision', :work_items, :work_item, no_controller_options, :work_item_id,
                      additional_yes_branch_tests: lambda {
                        it 'creates a new defendant on the claim' do
                          expect { decision_tree.destination }.to change(application.work_items, :count).by(1)
                        end
                      }
    end
  end
  it_behaves_like 'a decision with nested object',
    step_name: :work_item_delete, controller: :work_item,
    summary_controller: :work_items, form_class: Steps::DeleteForm

  it_behaves_like 'a decision with nested object',
    step_name: :letters_calls, controller: :disbursement_type, summary_controller: :disbursements,
    form_class: Steps::LettersCallsForm, edit_when_one: true, nested: :disbursement
  it_behaves_like 'a generic decision', :disbursement_cost, :disbursements, Steps::DefendantDeleteForm
  context 'when disbursements exists' do
    let(:application) { create(:claim, disbursements: [disbursement]) }
    let(:disbursement) { build(:disbursement, :valid) }

    let(:local_form) { Steps::DisbursementTypeForm.build(disbursement, application:) }
    let(:decision_tree) { described_class.new(local_form, as: :disbursement_type) }

    context "when step is disbursement_type" do
      it "moves to disbursement_cost#edit" do
        expect(decision_tree.destination).to eq(
          action: :edit,
          controller: :disbursement_cost,
          id: application,
          disbursement_id: disbursement.id
        )
      end
    end
    it_behaves_like 'an add_another decision', :disbursements, :disbursement_type, :cost_summary, :disbursement_id,
                    no_action_name: :show, additional_yes_branch_tests: lambda {
                      it 'creates a new defendant on the claim' do
                        expect { decision_tree.destination }.to change(application.disbursements, :count).by(1)
                      end
                    }
  end
  it_behaves_like 'a generic decision', :other_info, :start_page, Steps::OtherInfoForm, action_name: :show

  context 'when step is unknown' do
    it 'moves to claim index' do
      decision_tree = described_class.new(double('form'), as: :unknown)
      expect(decision_tree.destination).to eq(
        action: :index,
        controller: '/claims',
      )
    end
  end
end
