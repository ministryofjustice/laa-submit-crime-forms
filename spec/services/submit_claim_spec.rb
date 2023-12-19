require 'rails_helper'

RSpec.describe SubmitClaim do
  subject { described_class.new }

  let(:scorer) { double(:scorer) }
  let(:claim) { instance_double(Claim) }
  let(:message_builder) { instance_double(described_class::MessageBuilder, message: { some: 'message' }) }
  let(:submitted_claim) { instance_double(SubmittedClaim, assign_attributes: true, received_on: true) }

  before do
    allow(described_class::MessageBuilder).to receive(:new)
      .and_return(message_builder)
    allow(ClaimSubmissionMailer).to receive_message_chain(:notify, :deliver_later!)
  end

  describe '#process' do
    context 'when REDIS_HOST is not present' do
      before do
        allow(ENV).to receive(:key?).and_call_original
        allow(ENV).to receive(:key?).with('REDIS_HOST').and_return(false)
        allow(SubmittedClaim).to receive(:find_or_initialize_by).and_return(submitted_claim)
        allow(Event::NewVersion).to receive(:build)
        allow(submitted_claim).to receive(:save!).and_return(true)
      end

      it 'does not raise any errors' do
        expect { subject.process(claim:, scorer:) }.not_to raise_error
      end

      it 'creates a new SubmittedClaim instance' do
        expect(submitted_claim).to receive(:save!)
        subject.process(claim:, scorer:)
      end
    end

    context 'when REDIS_HOST is present' do
      before do
        allow(ENV).to receive(:key?).with('REDIS_HOST').and_return(true)
      end

      it 'schedules the job' do
        expect(described_class).to receive(:perform_later).with(claim)

        subject.process(claim:, scorer:)
      end
    end
  end

  describe '#perform' do
    before do
      allow(SubmittedClaim).to receive(:find_or_initialize_by).and_return(submitted_claim)
      allow(Event::NewVersion).to receive(:build)
      allow(submitted_claim).to receive(:save!).and_return(true)
    end

    it 'creates a new MessageBuilder' do
      expect(described_class::MessageBuilder).to receive(:new)
        .with(claim: claim, scorer: RiskAssessment::RiskAssessmentScorer)

      subject.perform(claim)
    end
  end

  describe '#notify' do
    context 'when SNS_URL is not present' do
      before do
        allow(SubmittedClaim).to receive(:find_or_initialize_by).and_return(submitted_claim)
        allow(Event::NewVersion).to receive(:build)
        allow(submitted_claim).to receive(:save!).and_return(true)
      end

      it 'creates a new SubmittedClaim instance' do
        expect(submitted_claim).to receive(:save!)
        subject.notify(message_builder)
      end
    end
  end
end
