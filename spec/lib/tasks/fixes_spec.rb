require 'rails_helper'

describe 'fixes:', type: :task do
  describe 'update_contact_email' do
    subject(:run) do
      Rake::Task['fixes:update_contact_email'].execute(arguments)
    end

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow($stdin).to receive_message_chain(:gets, :strip).and_return('y')
    end

    let(:arguments) { Rake::TaskArguments.new [:id, :new_contact_email], [submission.id, 'correct@email.address'] }
    let(:solicitor) { Solicitor.create(contact_email: 'wrong@email.address') }

    context 'with a claim' do
      let(:submission) { create(:claim, solicitor:) }

      it 'amends contact email' do
        expect { run }.to change { submission.solicitor.reload.contact_email }
          .from('wrong@email.address')
          .to('correct@email.address')
      end
    end

    context 'with a prior authority application' do
      let(:submission) { create(:prior_authority_application, solicitor:) }

      it 'amends contact email' do
        expect { run }.to change { submission.solicitor.reload.contact_email }
          .from('wrong@email.address')
          .to('correct@email.address')
      end
    end
  end
end
