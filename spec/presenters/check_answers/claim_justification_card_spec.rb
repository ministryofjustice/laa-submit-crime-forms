require 'rails_helper'

RSpec.describe CheckAnswers::ClaimJustificationCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:form) do
    instance_double(Steps::ReasonForClaimForm, reasons_for_claim:)
  end
  let(:reasons_for_claim) { [ReasonForClaim.new(:enhanced_rates_claimed), ReasonForClaim.new(:extradition)] }

  before do
    allow(Steps::ReasonForClaimForm).to receive(:build).and_return(form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::ReasonForClaimForm).to have_received(:build).with(claim)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Claim justification')
    end
  end

  describe '#row_data' do
    it 'generates claim justification row' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: 'reasons_for_claim',
            text: 'Enhanced rates claimed<br>Extradition'
          }
        ]
      )
    end
  end
end
