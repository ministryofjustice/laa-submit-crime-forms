require 'rails_helper'

RSpec.describe Tasks::HearingDetails, type: :system do
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
    it { expect(subject.path).to eq("/applications/#{id}/steps/hearing_details") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    context 'when plea is set' do
      let(:plea) { PleaOptions::GUILTY }

      it { expect(subject).to be_can_start }
    end

    context 'when plea is not set' do
      it { expect(subject).not_to be_can_start }
    end
  end

  describe '#completed?' do
    let(:application) { Hash.new('present_value') }

    context 'when all fields have been set' do
      it { expect(subject).to be_completed }
    end

    context 'when any fields are blank' do
      Steps::HearingDetailsForm.attribute_names.each do |attribute|
        before { application[attribute] = nil }

        it { expect(subject).not_to be_completed }
      end
    end
  end
end
