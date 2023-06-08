require 'rails_helper'

RSpec.describe Steps::DefendantDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DefendantDetailsForm, Decisions::SimpleDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::DefendantDetailsForm

  describe '#edit' do
    let(:application) { Claim.create(office_code: 'AA1', defendants: defendants) }
    let(:defendants) { [] }

    context 'when defendant_id is not passed in' do
      context 'when main defendant already exists' do
        let(:defendants) { [Defendant.new(full_name: 'Jim', maat: 'AA1', main: true, position: 1)] }

        it 'passes the existing defendant to the form' do
          allow(Steps::DefendantDetailsForm).to receive(:build)
          expect { get :edit, params: { id: application } }.not_to change(application.defendants, :count)

          expect(Steps::DefendantDetailsForm).to have_received(:build).with(defendants.first, application:)
        end
      end

      context 'when no main defendant exists' do
        it 'creates a new main defendant and passes it to the form' do
          allow(Steps::DefendantDetailsForm).to receive(:build)
          expect { get :edit, params: { id: application } }.to change(application.defendants, :count).by(1)

          expect(Steps::DefendantDetailsForm).to have_received(:build).with(application.reload.defendants.last,
                                                                            application:)
        end
      end
    end

    context 'when defendant_id is passed in' do
      context 'and defendant exists' do
        let(:defendants) { [Defendant.new(full_name: 'Jim', maat: 'AA1', main: true, position: 1)] }

        it 'passes the existing defendant to the form' do
          allow(Steps::DefendantDetailsForm).to receive(:build)
          expect do
            get :edit,
                params: { id: application, defendant_id: application.defendants.first.id }
          end.not_to change(application.defendants, :count)

          expect(Steps::DefendantDetailsForm).to have_received(:build).with(defendants.first, application:)
        end
      end

      context 'and defendant does not exists' do
        let(:defendants) { [Defendant.new(full_name: 'Jim', maat: 'AA1', main: true, position: 1)] }

        it 'redirect to the summary screen' do
          expect do
            get :edit, params: { id: application, defendant_id: SecureRandom.uuid }
          end.not_to change(application.defendants, :count)

          expect(response).to redirect_to(edit_steps_defendant_summary_path(application))
        end
      end
    end
  end
end
