require 'rails_helper'

describe 'fixes:', type: :task do
  describe 'multiple_primary_quotes:' do
    let(:service) { instance_double(Fixes::MultiplePrimaryQuoteFixer, identify: output, fix: true) }
    let(:output) { 'HERE IS SOME DATA' }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow(Fixes::MultiplePrimaryQuoteFixer).to receive(:new).and_return(service)
      allow($stdout).to receive(:puts)
    end

    describe 'identify' do
      subject { Rake::Task['fixes:multiple_primary_quotes:identify'].execute }

      it 'calls the right service and prints the output' do
        subject
        expect($stdout).to have_received(:puts).with(output)
      end
    end

    describe 'fix' do
      subject { Rake::Task['fixes:multiple_primary_quotes:fix'].execute }

      it 'calls the right service and prints the output' do
        subject
        expect(service).to have_received(:fix)
      end
    end
  end

  describe 'update_contact_email' do
    subject(:run) do
      Rake::Task['fixes:update_contact_email'].execute(arguments)
    end

    let(:arguments) { Rake::TaskArguments.new [:id, :new_contact_email], [submission.id, 'correct@email.address'] }
    let(:solicitor) { Solicitor.create(contact_email: 'wrong@email.address') }

    before { allow($stdin).to receive_message_chain(:gets, :strip).and_return('y') }

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
