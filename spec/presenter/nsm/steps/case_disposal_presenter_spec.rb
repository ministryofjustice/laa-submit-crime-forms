require 'rails_helper'

RSpec.describe Nsm::Tasks::CaseDisposal, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, id:, plea:, plea_category:, rep_order_date:, include_youth_court_fee:) }
  let(:id) { SecureRandom.uuid }
  let(:plea) { nil }
  let(:rep_order_date) { Date.new(2024, 12, 5) }
  let(:youth_court_fee_cutoff) { Date.new(2024, 12, 6) }
  let(:plea_category) { nil }
  let(:include_youth_court_fee) { nil }

  describe '#path' do
    context 'for a claim on or after the youth court fee cut off date' do
      let(:rep_order_date) { youth_court_fee_cutoff }

      it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{application.id}/steps/case_category") }
    end

    context 'for a claim before the youth court fee cut off date' do
      it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{application.id}/steps/case_disposal") }
    end
  end

  describe '#form' do
    context 'for a claim on or after the youth court fee cut off date' do
      let(:rep_order_date) { youth_court_fee_cutoff }

      it { expect(subject.form).to eq(Nsm::Steps::CaseCategoryForm) }
    end

    context 'for a claim before the youth court fee cut off date' do
      it { expect(subject.form).to eq(Nsm::Steps::CaseDisposalForm) }
    end
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#completed?' do
    context 'claim is elligible for youth court fee' do
      let(:application) { build(:claim, :valid_youth_court, plea:, include_youth_court_fee:) }
      let(:plea) { 'any' }

      context 'user chooses not to claim youth court fee' do
        let(:include_youth_court_fee) { false }

        it 'returns true' do
          expect(subject.completed?).to be(true)
        end
      end

      it 'returns false when user has not entered whether they want to claim youth court fee' do
        expect(subject.completed?).to be(false)
      end
    end

    context 'claim is not elligible for youth court fee' do
      context 'plea and plea_category are populated' do
        let(:plea) { 'any' }
        let(:plea_category) { 'any' }

        it 'returns true' do
          expect(subject.completed?).to be(true)
        end
      end

      context 'plea is nil' do
        let(:plea_category) { 'any' }

        it 'returns false' do
          expect(subject.completed?).to be(false)
        end
      end

      context 'plea category is nil' do
        let(:plea) { 'any' }

        it 'returns false' do
          expect(subject.completed?).to be(false)
        end
      end
    end
  end

  it_behaves_like 'a task with generic can_start?', Nsm::Tasks::HearingDetails

  describe '#in_progress?' do
    it { expect(subject).not_to be_in_progress }
  end
end
