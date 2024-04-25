require 'rails_helper'

RSpec.describe Nsm::Steps::DefendantDetailsController, type: :controller do
  let(:defendant) { existing_case.is_a?(Claim) ? existing_case.defendants.create : nil }

  it_behaves_like 'a generic step controller', Nsm::Steps::DefendantDetailsForm, Decisions::DecisionTree,
                  ->(scope) { { defendant_id: scope.defendant&.id || '4321' } }
  it_behaves_like 'a step that can be drafted', Nsm::Steps::DefendantDetailsForm,
                  ->(scope) { { defendant_id: scope.defendant&.id || '4321' } }

  describe '#edit' do
    let(:application) { create(:claim, defendants:) }
    let(:defendants) { [] }

    context 'when defendant_id NEW_RECORD flag passed as id' do
      it 'does not save the new defendant it passes to the form' do
        allow(Nsm::Steps::DefendantDetailsForm).to receive(:build)
        expect { get :edit, params: { id: application, defendant_id: Nsm::StartPage::NEW_RECORD } }
          .not_to change(application.defendants, :count)

        expect(Nsm::Steps::DefendantDetailsForm).to have_received(:build) do |defend, **kwargs|
          expect(defend).to be_a(Defendant)
          expect(defend).to be_new_record
          expect(kwargs).to eq(application:)
        end
      end
    end

    context 'when defendant_id is passed in' do
      context 'and defendant exists' do
        let(:defendants) { [Defendant.new(first_name: 'Jim', last_name: 'S', maat: '1234567', main: true, position: 1)] }

        it 'passes the existing defendant to the form' do
          allow(Nsm::Steps::DefendantDetailsForm).to receive(:build)
          expect do
            get :edit,
                params: { id: application, defendant_id: application.defendants.first.id }
          end.not_to change(application.defendants, :count)

          expect(Nsm::Steps::DefendantDetailsForm).to have_received(:build).with(defendants.first, application:)
        end
      end

      context 'and defendant does not exists' do
        let(:defendants) { [Defendant.new(first_name: 'Jim', last_name: 'S', maat: '1234567', main: true, position: 1)] }

        it 'redirect to the summary screen' do
          expect do
            get :edit, params: { id: application, defendant_id: SecureRandom.uuid }
          end.not_to change(application.defendants, :count)

          expect(response).to redirect_to(edit_nsm_steps_defendant_summary_path(application))
        end
      end
    end
  end
end
