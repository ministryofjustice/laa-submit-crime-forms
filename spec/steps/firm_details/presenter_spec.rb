require 'rails_helper'

RSpec.describe Tasks::FirmDetails, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.new(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      firm_office: firm_office,
      solicitor: solicitor,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:firm_office) { nil }
  let(:solicitor) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/firm_details") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    it { expect(subject).to be_can_start }
  end

  describe '#completed?' do
    let(:form) { instance_double(Steps::FirmDetailsForm, valid?: valid) }
    let(:valid) { true }

    before do
      allow(Steps::FirmDetailsForm).to receive(:build).and_return(form)
    end

    context 'when valid is true' do
      it { expect(subject).to be_completed }
    end

    context 'when valid is false' do
      let(:valid) { false }

      it { expect(subject).not_to be_completed }
    end
  end
end
