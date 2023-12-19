require 'rails_helper'

RSpec.describe Assess::SendBackForm do
  subject { described_class.new(params) }

  let(:claim) { create(:submitted_claim) }

  describe '#validations' do
    context 'when state is not set' do
      let(:params) { {} }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:state, :inclusion)).to be(true)
      end
    end

    context 'when state is invalid' do
      let(:params) { { claim: claim, state: 'other' } }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:state, :inclusion)).to be(true)
      end
    end

    context 'when state is further_info' do
      let(:params) { { claim: claim, state: 'further_info', comment: comment } }
      let(:comment) { 'some comment' }

      it { expect(subject).to be_valid }

      context 'when comment is blank' do
        let(:comment) { nil }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:comment, :blank)).to be(true)
        end
      end
    end

    context 'when state is provider_requested' do
      context 'when comment is blank' do
        let(:params) { { claim: claim, state: 'provider_requested', comment: nil } }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:comment, :blank)).to be(true)
        end
      end

      context 'when comment is set' do
        let(:params) { { claim: claim, state: 'provider_requested', comment: 'part grant comment' } }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe '#persistance' do
    let(:user) { instance_double(User) }
    let(:claim) { create(:submitted_claim) }
    let(:original_claim) { create(:claim, id: claim.id) }
    let(:params) { { claim: claim, state: 'further_info', comment: 'some comment', current_user: user } }

    before do
      original_claim
      allow(Event::SendBack).to receive(:build)
    end

    it { expect(subject.save).to be_truthy }

    it 'updates the claim' do
      subject.save
      expect(claim.reload).to have_attributes(state: 'further_info')
    end

    it 'creates a Decision event' do
      subject.save
      expect(Event::SendBack).to have_received(:build).with(
        claim: claim, comment: 'some comment', previous_state: 'submitted', current_user: user
      )
    end

    it 'trigger an update to the app store' do
      subject.save
      # TODO: Expect original claim to have been updated
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end

    context 'when error during save' do
      before do
        allow(SubmittedClaim).to receive(:find_by).and_return(claim)
        allow(claim).to receive(:update!).and_raise('not found')
      end

      it { expect { subject.save }.to raise_error('not found') }
    end
  end
end
