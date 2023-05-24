require 'rails_helper'

RSpec.describe Tasks::DefendantDetails, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.new(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      defendants_attributes: defendants_attributes,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:defendants_attributes) { [] }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/defendant_details") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    let(:hearing_details) { instance_double(Tasks::HearingDetails, status:) }

    before do
      allow(Tasks::HearingDetails).to receive(:new).and_return(hearing_details)
    end

    context 'when hearing details are complete' do
      let(:status) { TaskStatus::COMPLETED }

      it { expect(subject).to be_can_start }
    end

    context 'when hearing details are not complete' do
      let(:status) { TaskStatus::IN_PROGRESS }

      it { expect(subject).not_to be_can_start }
    end
  end

  describe '#completed?' do
    context 'when no defendants exist' do
      it { expect(subject).not_to be_completed }
    end

    context 'when defendants exist' do
      let(:defendants_attributes) { [{ full_name: 'Jim Bob' }] }
      let(:defendant_form) { double(:defendant_form, valid?: valid) }

      before do
        allow(Steps::DefendantsDetailsForm).to receive(:new).and_return(defendant_form)
      end

      context 'when they are not valid' do
        let(:valid) { false }

        it { expect(subject).not_to be_completed }
      end

      context 'when they are valid' do
        let(:valid) { true }

        it { expect(subject).to be_completed }
      end
    end
  end
end
