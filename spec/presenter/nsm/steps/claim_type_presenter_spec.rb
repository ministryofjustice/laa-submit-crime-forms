require 'rails_helper'

RSpec.describe Nsm::Tasks::ClaimType, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      firm_office:,
      solicitor:,
      court_in_undesignated_area:,
      office_in_undesignated_area:,
      transferred_from_undesignated_area:,
      claim_type:,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:firm_office) { nil }
  let(:solicitor) { nil }
  let(:court_in_undesignated_area) { nil }
  let(:office_in_undesignated_area) { nil }
  let(:transferred_from_undesignated_area) { nil }
  let(:claim_type) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{id}/steps/claim_type") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    it { expect(subject).to be_can_start }
  end

  describe '#completed?' do
    it { expect(subject).not_to be_completed }

    context 'when BOI' do
      let(:claim_type) { 'breach_of_injunction' }

      it { expect(subject).to be_completed }
    end

    context 'when court payment' do
      let(:claim_type) { 'non_standard_magistrate' }

      it { expect(subject).not_to be_completed }

      context 'when undesignated office' do
        let(:office_in_undesignated_area) { true }

        it { expect(subject).not_to be_completed }

        context 'when undesignated court' do
          let(:court_in_undesignated_area) { true }

          it { expect(subject).to be_completed }
        end

        context 'when not undesignated court' do
          let(:court_in_undesignated_area) { false }

          it { expect(subject).not_to be_completed }

          context 'when case tranferred' do
            let(:transferred_from_undesignated_area) { true }

            it { expect(subject).to be_completed }
          end

          context 'when not case transferred' do
            let(:transferred_from_undesignated_area) { false }

            it { expect(subject).to be_completed }
          end
        end
      end

      context 'when not undesignated office' do
        let(:office_in_undesignated_area) { false }

        it { expect(subject).to be_completed }
      end
    end
  end
end
