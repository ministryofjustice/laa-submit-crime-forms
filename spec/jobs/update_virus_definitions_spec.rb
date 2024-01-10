require 'rails_helper'

RSpec.describe UpdateVirusDefinitions do
  before do
    allow(Clamby).to receive(:update)
  end

  context 'when job initiated' do
    it 'calls update on clamby' do
      subject.perform
      expect(Clamby).to have_received(:update)
    end
  end
end
