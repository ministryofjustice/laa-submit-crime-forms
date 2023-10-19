require 'rails_helper'

RSpec.describe NotifyAppStore do
  subject { described_class.new }

  let(:scorer) { double(:scorer) }
  let(:claim) { instance_double(Claim) }
  let(:message_builder) { instance_double(described_class::MessageBuilder, message: { some: 'message' }) }

  before do
    allow(described_class::MessageBuilder).to receive(:new)
      .and_return(message_builder)
  end

  describe '#process' do
    context 'when REDIS_HOST is not present' do
      before do
        allow(ENV).to receive(:key?).and_call_original
        allow(ENV).to receive(:key?).with('REDIS_HOST').and_return(false)
        expect(described_class::HttpNotifier).to receive(:new)
          .and_return(http_notifier)
      end

      let(:http_notifier) { instance_double(described_class::HttpNotifier, post: true) }

      it 'does not raise any errors' do
        expect { subject.process(claim:, scorer:) }.not_to raise_error
      end

      it 'sends a HTTP message' do
        expect(http_notifier).to receive(:post).with(message_builder.message)

        subject.process(claim:, scorer:)
      end

      describe 'when error during notify process' do
        before do
          allow(http_notifier).to receive(:post).and_raise('annoying_error')
        end

        it 'sends the error to sentry and ignores it' do
          expect(Sentry).to receive(:capture_exception)

          expect { subject.process(claim:, scorer:) }.not_to raise_error
        end
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
    let(:http_notifier) { instance_double(described_class::HttpNotifier, post: true) }

    before do
      allow(described_class::HttpNotifier).to receive(:new)
        .and_return(http_notifier)
    end

    it 'creates a new MessageBuilder' do
      expect(described_class::MessageBuilder).to receive(:new)
        .with(claim: claim, scorer: RiskAssessment::RiskAssessmentScorer)

      subject.perform(claim)
    end
  end

  describe '#notify' do
    context 'when SNS_URL is not present' do
      let(:http_notifier) { instance_double(described_class::HttpNotifier, post: true) }

      before do
        allow(described_class::HttpNotifier).to receive(:new)
          .and_return(http_notifier)
      end

      it 'creates a new HttpNotifier instance' do
        expect(described_class::HttpNotifier).to receive(:new)

        subject.notify(message_builder)
      end

      it 'sends a HTTP message' do
        expect(http_notifier).to receive(:post).with(message_builder.message)

        subject.notify(message_builder)
      end

      describe 'when error during notify process' do
        before do
          allow(http_notifier).to receive(:post).and_raise('annoying_error')
        end

        it 'allows the error to be raised - should reset the sidekiq job' do
          expect { subject.notify(message_builder) }.to raise_error('annoying_error')
        end
      end
    end

    context 'when SNS_URL is present' do
      before do
        allow(ENV).to receive(:key?).with('SNS_URL').and_return(true)
      end

      it 'raises an error' do
        expect { subject.notify(message_builder) }.to raise_error('SNS notification is not yet enabled')
      end
    end
  end
end
