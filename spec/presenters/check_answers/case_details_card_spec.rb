require 'rails_helper'

RSpec.describe CheckAnswers::CaseDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:form) { instance_double(Steps::CaseDetailsForm) }

  before do
    allow(Steps::CaseDetailsForm).to receive(:build).and_return(form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::CaseDetailsForm).to have_received(:build).with(claim)
    end
  end
end
