require 'rails_helper'

RSpec.describe Assess::UnassignmentForm do
  subject { described_class.new(params) }

  let(:claim) { create(:submitted_claim) }

  describe '#unassignment_user' do
    let(:params) { { claim: claim, current_user: user } }
    let(:claim) { create(:submitted_claim, :with_assignment) }

    context 'when assigned user and current_user are the same' do
      let(:user) { claim.assignments.first.user }

      it { expect(subject.unassignment_user).to eq('assigned') }
    end

    context 'when assigned user and current_user are different' do
      let(:user) { instance_double(User) }

      it { expect(subject.unassignment_user).to eq('other') }
    end
  end

  describe '#validations' do
    context 'when comment is blank' do
      let(:params) { { claim: claim, comment: nil } }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:comment, :blank)).to be(true)
      end
    end

    context 'when comment is set' do
      let(:params) { { claim: claim, comment: 'part grant comment' } }

      it { expect(subject).to be_valid }
    end
  end

  describe '#persistance' do
    let(:user) { instance_double(User) }
    let(:claim) { create(:submitted_claim, :with_assignment) }
    let(:params) { { claim: claim, comment: 'some comment', current_user: user } }

    before do
      allow(Event::Unassignment).to receive(:build)
    end

    it { expect(subject.save).to be_truthy }

    it 'remove the assignment' do
      expect(claim.reload.assignments).not_to eq([])
      subject.save
      expect(claim.reload.assignments).to eq([])
    end

    it 'creates a Unassignment event' do
      assigned_user = claim.assignments.first.user
      subject.save
      expect(Event::Unassignment).to have_received(:build).with(
        claim: claim, comment: 'some comment', current_user: user, user: assigned_user
      )
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end

    context 'if no assigned user' do
      let(:claim) { create(:submitted_claim) }

      it 'does not raise any errors' do
        expect(subject.save).to be_truthy
      end

      it 'does not create an Event' do
        subject.save
        expect(Event::Unassignment).not_to have_received(:build)
      end
    end

    context 'when error during save' do
      before do
        allow(SubmittedClaim).to receive(:find_by).and_return(claim)
        allow(claim.assignments).to receive(:first).and_raise('not found')
      end

      it { expect { subject.save }.to raise_error('not found') }
    end
  end
end
