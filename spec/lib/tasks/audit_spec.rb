require 'rails_helper'

describe 'audit:', type: :task do
  describe 'office_codes' do
    subject { Rake::Task['audit:office_codes'].execute(arguments) }

    let(:arguments) { Rake::TaskArguments.new [:codes, :since], ['AAAAA|BBBBB', '2024-06-01'] }
    let(:service) { instance_double(Auditor, call: output) }
    let(:output) { 'OUTPUT' }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow(Auditor).to receive(:new).and_return(service)
      allow($stdout).to receive(:puts)
    end

    it 'calls the right service and prints the output' do
      subject
      expect(Auditor).to have_received(:new).with(%w[AAAAA BBBBB], Date.new(2024, 6, 1))
      expect($stdout).to have_received(:puts).with(output)
    end
  end
end
