require 'rails_helper'

RSpec.describe Tasks::CaseDetails, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.create(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      plea: plea
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:plea) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/case_details") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    let(:firm_details) { instance_double(Tasks::FirmDetails, status:) }

    before do
      allow(Tasks::FirmDetails).to receive(:new).and_return(firm_details)
    end

    context 'when case details are complete' do
      let(:status) { TaskStatus::COMPLETED }

      it { expect(subject).to be_can_start }
    end

    context 'when case details are not complete' do
      let(:status) { TaskStatus::IN_PROGRESS }

      it { expect(subject).not_to be_can_start }
    end
  end

  describe '#completed?' do
    let(:form) { instance_double(Steps::CaseDetailsForm, valid?: valid) }

    before do
      allow(Steps::CaseDetailsForm).to receive(:new).and_return(form)
    end

    context 'when status is valid' do
      let(:valid) { true }

      it { expect(subject).to be_completed }
    end

    context 'when status not is valid' do
      let(:valid) { false }

      it { expect(subject).not_to be_completed }
    end
  end
end
