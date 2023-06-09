require 'rails_helper'

RSpec.describe Decisions::SimpleDecisionTree do
  let(:application) { Claim.new(id: SecureRandom.uuid, office_code: 'AA1') }

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

  it_behaves_like 'a generic decision', :firm_details, :case_details, Steps::FirmDetailsForm
  it_behaves_like 'a generic decision', :case_disposal, :hearing_details, Steps::CaseDisposalForm
  it_behaves_like 'a generic decision', :hearing_details, :defendant_details, Steps::HearingDetailsForm
  it_behaves_like 'a generic decision', :defendant_details, :defendant_summary, Steps::DefendantDetailsForm
  it_behaves_like 'a generic decision', :defendant_delete, :defendant_summary, Steps::DefendantDeleteForm
  context 'when defendant exists' do
    before do
      application.save
      application.defendants.create(full_name: 'Jim', maat: 'aaa', position: 1)
    end

    it_behaves_like 'a generic decision', :hearing_details, :defendant_summary, Steps::DefendantDetailsForm
    it_behaves_like 'an add_another decision', :defendant_summary, :defendant_details, :reason_for_claim, :defendant_id,
                    additional_yes_branch_tests: lambda {
                      it 'creates a new defendant on the claim' do
                        expect { decision_tree.destination }.to change(application.defendants, :count).by(1)
                      end
                    }
  end

  it_behaves_like 'a generic decision', :reason_for_claim, :claim_details, Steps::ReasonForClaimForm
  it_behaves_like 'a generic decision', :claim_details, :work_item, Steps::ClaimDetailsForm
  it_behaves_like 'a generic decision', :work_item, :work_items, Steps::WorkItemForm
  it_behaves_like 'a generic decision', :work_item_delete, :work_item, Steps::DeleteForm

  context 'when work_item exists' do
    before do
      application.save
      application.work_items.create
    end

  context 'when step is letters_calls' do
    it 'moves to other_info' do
      claim = Steps::LettersCallsForm.new(application:)
      decision_tree = described_class.new(claim, as: :letters_calls)
      expect(decision_tree.destination).to eq(
        action: :edit,
        controller: :other_info,
        id: application
      )
    end
  end

  context 'when step is other_info' do
    it 'moves to start_page' do
      claim = Steps::LettersCallsForm.new(application:)
      decision_tree = described_class.new(claim, as: :other_info)
      expect(decision_tree.destination).to eq(
        action: :show,
        controller: :start_page,
        id: application
      )
    end
    
    it_behaves_like 'a generic decision', :work_item_delete, :work_items, Steps::DeleteForm
    it_behaves_like 'a generic decision', :claim_details, :work_items, Steps::ClaimDetailsForm
    it_behaves_like 'an add_another decision', :work_items, :work_item, :letters_calls, :work_item_id,
                    additional_yes_branch_tests: lambda {
                      it 'creates a new defendant on the claim' do
                        expect { decision_tree.destination }.to change(application.work_items, :count).by(1)
                      end
                    }
  end

  it_behaves_like 'a generic decision', :letters_calls, :start_page, Steps::LettersCallsForm, action_name: :show

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
