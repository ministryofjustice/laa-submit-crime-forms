require 'rails_helper'

RSpec.describe Steps::SupportingEvidenceForm do
  let(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      send_by_post:
    }
  end

  let(:application) { instance_double(Claim, update!: true) }

  context 'when send_by_post is yes' do
    let(:send_by_post) { 'yes' }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'saves the form' do
      expect(form.save).to be_truthy
    end
  end

  context 'when send_by_post is no' do
    let(:send_by_post) { 'no' }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'saves the form' do
      expect(form.save).to be_truthy
    end
  end
end
