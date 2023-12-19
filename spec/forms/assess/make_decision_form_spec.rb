require 'rails_helper'

RSpec.describe Assess::MakeDecisionForm do
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

    context 'when state is granted' do
      let(:params) { { claim: claim, state: 'granted' } }

      it { expect(subject).to be_valid }
    end

    context 'when state is part_grant' do
      context 'when partial_comment is blank' do
        let(:params) { { claim: claim, state: 'part_grant', partial_comment: nil } }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:partial_comment, :blank)).to be(true)
        end
      end

      context 'when partial_comment is set' do
        let(:params) { { claim: claim, state: 'part_grant', partial_comment: 'part grant comment' } }

        it { expect(subject).to be_valid }
      end
    end

    context 'when state is rejected' do
      context 'when reject_comment is blank' do
        let(:params) { { claim: claim, state: 'rejected', reject_comment: nil } }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:reject_comment, :blank)).to be(true)
        end
      end

      context 'when reject_comment is set' do
        let(:params) { { claim: claim, state: 'rejected', reject_comment: 'reject comment' } }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe '#persistance' do
    let(:user) { instance_double(User) }
    let(:claim) { create(:submitted_claim) }
    let(:original_claim) { create(:claim, id: claim.id) }
    let(:params) do
      { claim: claim, state: 'part_grant', partial_comment: 'part comment', current_user: user }
    end

    before do
      original_claim
      allow(Event::Decision).to receive(:build)
    end

    it { expect(subject.save).to be_truthy }

    it 'updates the claim' do
      subject.save
      expect(claim.reload).to have_attributes(state: 'part_grant')
    end

    it 'creates a Decision event' do
      subject.save
      expect(Event::Decision).to have_received(:build).with(
        claim: claim, comment: 'part comment', previous_state: 'submitted', current_user: user
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

  describe '#comment' do
    let(:params) { { state: state, partial_comment: 'part comment', reject_comment: 'reject comment' } }

    context 'when state is granted' do
      let(:state) { 'granted' }

      it 'ignores all comment fields' do
        expect(subject.comment).to be_nil
      end
    end

    context 'when state is part_grant' do
      let(:state) { 'part_grant' }

      it 'uses the partial_comment field' do
        expect(subject.comment).to eq('part comment')
      end
    end

    context 'when state is rejected' do
      let(:state) { 'rejected' }

      it 'uses the reject_comment field' do
        expect(subject.comment).to eq('reject comment')
      end
    end
  end
end
