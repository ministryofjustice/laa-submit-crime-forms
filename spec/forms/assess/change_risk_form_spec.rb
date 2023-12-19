require 'rails_helper'

RSpec.describe Assess::ChangeRiskForm, type: :model do
  let(:user) { instance_double(User) }
  let(:claim) { create(:submitted_claim) }

  describe '#available_risks' do
    context 'when the claim has a risk level' do
      let(:claim) { create(:submitted_claim, risk: 'medium') }
      let(:form) do
        described_class.new(id: claim.id, risk_level: 'medium', explanation: 'Risk level changed', current_user: user)
      end

      it 'returns the available risks excluding the current risk level' do
        result = form.available_risks
        expect(result.map(&:level)).to eq(['Low risk', 'High risk'])
      end
    end
  end

  describe '#validations' do
    subject { described_class.new(id:, risk_level:, explanation:) }

    let(:id) { claim.id }
    let(:risk_level) { 'high' }
    let(:explanation) { 'changed to high' }

    context 'risk_level' do
      %w[high medium].each do |valid_risk|
        context "when risk is #{valid_risk}" do
          let(:risk_level) { valid_risk }

          it { expect(subject).to be_valid }
        end
      end

      context 'when risk level is unchanged' do
        let(:risk_level) { 'low' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:risk_level, :unchanged)).to be(true)
        end
      end

      context 'when risk level is something else' do
        let(:risk_level) { 'other' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:risk_level, :inclusion)).to be(true)
        end
      end
    end

    describe 'explanation' do
      context 'when it is blank' do
        let(:explanation) { '' }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:explanation, :blank)).to be(true)
        end

        context 'but the risk level has not changed' do
          let(:risk_level) { 'low' }

          it 'is does not raise an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:explanation, :blank)).to be(false)
          end
        end
      end
    end
  end

  describe '#save' do
    subject { described_class.new(params) }

    let(:params) { { id: claim.id, risk_level: risk_level, explanation: 'Test', current_user: user } }
    let(:risk_level) { 'high' }

    before do
      allow(Event::ChangeRisk).to receive(:build)
    end

    it 'updates the claim' do
      subject.save
      expect(claim.reload).to have_attributes(risk: 'high')
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end

    it 'creates a ChangeRisk event' do
      subject.save
      expect(Event::ChangeRisk).to have_received(:build).with(
        claim: claim, explanation: 'Test', previous_risk_level: 'low', current_user: user
      )
    end

    context 'when error during save' do
      before do
        allow(SubmittedClaim).to receive(:find_by).and_return(claim)
        allow(claim).to receive(:update!).and_raise(StandardError)
      end

      it { expect(subject.save).to be_falsey }
    end
  end

  describe '#claim' do
    subject { described_class.new(id: claim.id) }

    it 'returns the claim with the given id' do
      expect(subject.claim).to eq(claim)
    end
  end
end
