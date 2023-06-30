require 'rails_helper'

RSpec.describe Steps::DisbursementTypeController, type: :controller do
  let(:disbursement) { existing_case.is_a?(Claim) ? existing_case.disbursements.create : nil }

  it_behaves_like 'a generic step controller', Steps::DisbursementTypeForm, Decisions::SimpleDecisionTree,
                  ->(scope) { { disbursement_id: scope.disbursement&.id || '4321' } }
  it_behaves_like 'a step that can be drafted', Steps::DisbursementTypeForm,
                  ->(scope) { { disbursement_id: scope.disbursement&.id || '4321' } }

  describe '#edit' do
    let(:application) { Claim.create(office_code: 'AA1', disbursements: disbursements) }
    let(:disbursements) { [] }

    context 'and disbursement exists' do
      let(:disbursements) { [Disbursement.new] }

      it 'passes the existing disbursement to the form' do
        allow(Steps::DisbursementTypeForm).to receive(:build)
        expect do
          get :edit,
              params: { id: application, disbursement_id: application.disbursements.first.id }
        end.not_to change(application.disbursements, :count)

        expect(Steps::DisbursementTypeForm).to have_received(:build).with(disbursements.first, application:)
      end
    end

    context 'and disbursement not found' do
      let(:work_items) { [] }

      it 'redirects to the summary page' do
        expect do
          get :edit, params: { id: application, disbursement_id: SecureRandom.uuid }
        end.not_to change(application.disbursements, :count)

        expect(response).to redirect_to(edit_steps_work_items_path(application))
      end
    end

    context 'when disbursement_id is CREATE_FIRST flag' do
      it 'creates a new main work_item and passes it to the form' do
        allow(Steps::DisbursementTypeForm).to receive(:build)
        expect { get :edit, params: { id: application, disbursement_id: StartPage::CREATE_FIRST } }
          .to change(application.disbursements, :count).by(1)

        expect(Steps::DisbursementTypeForm).to have_received(:build)
          .with(application.reload.disbursements.last, application:)
      end

      context 'and more than disbursement item exists' do
        let(:disbursements) { [Disbursement.new, Disbursement.new] }

        it 'redirects to the summary page' do
          expect do
            get :edit, params: { id: application, disbursement_id: StartPage::CREATE_FIRST }
          end.not_to change(application.disbursements, :count)

          # TODO: update this once we have disbusrements page
          expect(response).to redirect_to(edit_steps_work_items_path(application))
        end
      end
    end
  end
end
