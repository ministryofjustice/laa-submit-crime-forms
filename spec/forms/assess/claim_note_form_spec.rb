require 'rails_helper'

RSpec.describe Assess::ClaimNoteForm do
  subject { described_class.new(params) }

  let(:claim) { create(:submitted_claim) }

  describe '#validations' do
    context 'when note is not set' do
      let(:params) { {} }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:note, :blank)).to be(true)
      end
    end
  end

  describe '#persistance' do
    let(:user) { instance_double(User) }
    let(:claim) { create(:submitted_claim) }
    let(:params) { { id: claim.id, note: 'this is a note', current_user: user } }

    before do
      allow(Event::Note).to receive(:build)
    end

    it { expect(subject.save).to be_truthy }

    it 'creates a Note event' do
      subject.save
      expect(Event::Note).to have_received(:build).with(
        claim: claim, note: 'this is a note', current_user: user
      )
    end

    context 'when not valid' do
      let(:params) { {} }

      it { expect(subject.save).to be_falsey }
    end

    context 'when error during event creation' do
      before do
        allow(Event::Note).to receive(:build).and_raise(StandardError)
      end

      it { expect(subject.save).to be_falsey }
    end
  end
end
