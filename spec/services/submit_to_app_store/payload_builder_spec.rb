require 'rails_helper'

RSpec.describe SubmitToAppStore::PayloadBuilder do
  subject { described_class.call(submission) }

  let(:builder) { instance_double(SubmitToAppStore::NsmPayloadBuilder, payload: 'foo') }

  context 'when submission is a claim' do
    let(:submission) { create(:claim) }

    it 'delegates to NsmPayloadBuilder' do
      expect(SubmitToAppStore::NsmPayloadBuilder).to receive(:new).with(claim: submission).and_return(builder)
      subject
    end
  end

  context 'when submission is a PA application' do
    let(:submission) { create(:prior_authority_application) }

    it 'delegates to NsmPayloadBuilder' do
      expect(SubmitToAppStore::PriorAuthorityPayloadBuilder).to(
        receive(:new).with(application: submission).and_return(builder)
      )
      subject
    end
  end

  context 'when submission is unrecognised' do
    let(:submission) { 'something else' }

    it 'raises an error' do
      expect { subject }.to raise_error 'Unknown submission type'
    end
  end
end
