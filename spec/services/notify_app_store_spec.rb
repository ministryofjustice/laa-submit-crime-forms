require 'rails_helper'

RSpec.describe NotifyAppStore do
  subject { described_class.new(claim:, scorer:) }

  let(:scorer) { double(:scorer) }
  let(:claim) { instance_double(Claim) }
  let(:message_builder) { instance_double(described_class::MessageBuilder, message: { some: 'message' }) }

  before do
    allow(described_class::MessageBuilder).to receive(:new)
      .and_return(message_builder)
  end

  it 'creates a new MessageBuilder instance' do
    expect(described_class::MessageBuilder).to receive(:new)
      .with(claim:, scorer:)

    subject
  end

  context 'when no SNS_URL is present' do
    let(:http_notifier) { instance_double(described_class::HttpNotifier, post: true) }
    before do
      expect(described_class::HttpNotifier).to receive(:new)
        .and_return(http_notifier)
    end

    it 'creates a new HttpNotifier instance' do
      expect(described_class::MessageBuilder).to receive(:new)

      subject.notify
    end

    it 'sends a HTTP message' do
      expect(http_notifier).to receive(:post).with(message_builder.message)

      subject.notify
    end
  end

  context 'when SNS_URL is present' do
    before do
      allow(ENV).to receive(:key?).with('SNS_URL').and_return(double)
    end

    it 'raises an error' do
      expect { subject.notify }.to raise_error('SNS notification is not yet enabled')
    end
  end
end
