require 'rails_helper'

RSpec.describe Nsm::Steps::DisbursementTypeController, type: :controller do
  let(:disbursement) { existing_case.is_a?(Claim) ? existing_case.disbursements.create : nil }

  it_behaves_like 'a generic step controller', Nsm::Steps::DisbursementTypeForm, Decisions::DecisionTree,
                  ->(scope) { { disbursement_id: scope.disbursement&.id || '4321' } }
  it_behaves_like 'a step that can be drafted', Nsm::Steps::DisbursementTypeForm,
                  ->(scope) { { disbursement_id: scope.disbursement&.id || '4321' } }

  describe '#edit' do
    let(:application) { create(:claim, disbursements:) }
    let(:disbursements) { [] }

    context 'and disbursement exists' do
      let(:disbursements) { [Disbursement.new] }

      it 'passes the existing disbursement to the form' do
        allow(Nsm::Steps::DisbursementTypeForm).to receive(:build)
        expect do
          get :edit,
              params: { id: application, disbursement_id: application.disbursements.first.id }
        end.not_to change(application.disbursements, :count)

        expect(Nsm::Steps::DisbursementTypeForm).to have_received(:build).with(disbursements.first, application:)
      end
    end

    context 'and disbursement not found' do
      let(:disbursements) { [] }

      it 'redirects to the summary page' do
        expect do
          get :edit, params: { id: application, disbursement_id: SecureRandom.uuid }
        end.not_to change(application.disbursements, :count)

        expect(response).to redirect_to(edit_nsm_steps_disbursements_path(application))
      end
    end

    context 'when disbursement_id is NEW_RECORD flag' do
      it 'does not save the new disbursement passed to the form' do
        allow(Nsm::Steps::DisbursementTypeForm).to receive(:build)
        expect { get :edit, params: { id: application, disbursement_id: Nsm::StartPage::NEW_RECORD } }
          .not_to change(application.disbursements, :count)

        expect(Nsm::Steps::DisbursementTypeForm).to have_received(:build) do |disb, **kwargs|
          expect(disb).to be_a(Disbursement)
          expect(disb).to be_new_record
          expect(kwargs).to eq(application:)
        end
      end
    end
  end

  describe '#duplicate' do
    let(:application) { create(:claim) }
    let(:disbursement) { nil }

    before do
      application
      disbursement
    end

    context 'when existing disbursement_id is passed in' do
      let(:disbursement) { create(:disbursement, claim: application) }

      it 'creates a duplicate disbursement and redirects to the edit disbursement type page' do
        expect do
          get :duplicate, params: { id: application, disbursement_id: disbursement.id }
        end.to change(application.disbursements, :count).by(1)

        new_record_id = application.disbursements.pluck(:id).detect { |id| id != disbursement.id }
        expect(response).to redirect_to(edit_nsm_steps_disbursement_type_path(application, disbursement_id: new_record_id))
      end
    end

    context 'when existing disbursement_id is NEW_RECORD' do
      let(:disbursement) { build(:disbursement, id: Nsm::StartPage::NEW_RECORD) }

      it 'redirects to the NEW_RECORD page' do
        expect do
          get :duplicate, params: { id: application, disbursement_id: disbursement.id }
        end.not_to change(application.disbursements, :count)

        expect(response).to redirect_to(edit_nsm_steps_disbursement_type_path(application,
                                                                              disbursement_id: Nsm::StartPage::NEW_RECORD))
      end
    end

    context 'when unknown disbursement_id is passed in' do
      it 'redirects to the summary page' do
        expect do
          get :duplicate, params: { id: application, disbursement_id: SecureRandom.uuid }
        end.not_to change(application.disbursements, :count)

        expect(response).to redirect_to(edit_nsm_steps_disbursements_path(application))
      end
    end
  end
end
