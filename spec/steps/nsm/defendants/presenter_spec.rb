require 'rails_helper'

RSpec.describe Nsm::Tasks::Defendants, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      defendants:,
      navigation_stack:,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:defendants) { [] }
  let(:navigation_stack) { [] }

  describe '#path' do
    context 'no defendants' do
      it { expect(subject.path).to eq("/applications/#{id}/steps/defendant_details/#{StartPage::NEW_RECORD}") }
    end

    context 'one defendant' do
      let(:defendants) { [build(:defendant, :valid)] }

      it { expect(subject.path).to eq("/applications/#{id}/steps/defendant_summary") }
    end

    context 'more than one defendants' do
      let(:defendants) { [build(:defendant, :valid), build(:defendant, :valid)] }

      it { expect(subject.path).to eq("/applications/#{id}/steps/defendant_summary") }
    end
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  it_behaves_like 'a task with generic can_start?', Nsm::Tasks::FirmDetails

  describe 'in_progress?' do
    context 'navigation_stack include edit defentant_details path' do
      before { navigation_stack << edit_steps_defendant_details_path(application, defendant_id: '345') }

      it { expect(subject).to be_in_progress }
    end

    context 'navigation_stack include edit defentant_summary path' do
      before { navigation_stack << edit_steps_defendant_summary_path(application) }

      it { expect(subject).to be_in_progress }
    end

    context 'navigation_stack does not include defendant paths' do
      it { expect(subject).not_to be_in_progress }
    end
  end

  describe '#completed?' do
    context 'when no defendants exist' do
      it { expect(subject).not_to be_completed }
    end

    context 'when defendants exist' do
      let(:defendants) { [Defendant.new(full_name: 'Jim Bob')] }
      let(:defendant_form) { double(:defendant_form, valid?: valid) }

      before do
        allow(Nsm::Steps::DefendantDetailsForm).to receive(:build).and_return(defendant_form)
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
