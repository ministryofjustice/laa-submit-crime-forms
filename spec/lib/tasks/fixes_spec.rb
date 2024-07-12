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
end
