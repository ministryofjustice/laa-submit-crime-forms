# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RiskAssessment::LowRiskAssessment do
  subject { described_class.new(claim) }

  let(:claim) { create(:claim, work_items:, prosecution_evidence:) }
  let(:work_items) { [attendance_work_item, advocacy_work_item, preparation_work_item] }
  let(:attendance_work_item) { build(:work_item, work_type: 'attendance_with_counsel', time_spent: attendance_time_spent) }
  let(:preparation_work_item) { build(:work_item, work_type: 'preparation', time_spent: preparation_time_spent) }
  let(:advocacy_work_item) { build(:work_item, work_type: 'advocacy', time_spent: advocacy_time_spent) }
  let(:attendance_time_spent) { nil }
  let(:advocacy_time_spent) { nil }
  let(:preparation_time_spent) { nil }
  let(:prosecution_evidence) { nil } # Multiplied by 4 to get alternative prep time

  describe '#assess' do
    context 'when raw prep time is less than twice advocacy' do
      let(:preparation_time_spent) { 39 }
      let(:advocacy_time_spent) { 20 }

      context 'when attendance is less than twice advocacy' do
        let(:attendance_time_spent) { 39 }

        it { expect(subject.assess).to be_truthy }
      end

      context 'when attendance is more than twice advocacy' do
        let(:attendance_time_spent) { 41 }

        it { expect(subject.assess).to be_falsey }
      end
    end

    context 'when raw prep time is greater than advocacy' do
      let(:preparation_time_spent) { 41 }
      let(:advocacy_time_spent) { 20 }

      context 'when attendance is less than twice advocacy' do
        let(:attendance_time_spent) { 39 }

        context 'when alternative prep time is less than twice advocacy' do
          let(:prosecution_evidence) { 9 }

          it { expect(subject.assess).to be_truthy }
        end

        context 'when alternative prep time is greater than twice advocacy' do
          let(:prosecution_evidence) { 11 }

          it { expect(subject.assess).to be_falsey }
        end
      end

      context 'when attendance is more than twice advocacy' do
        let(:attendance_time_spent) { 41 }

        context 'when alternative prep time is less than twice advocacy' do
          let(:prosecution_evidence) { 9 }

          it { expect(subject.assess).to be_falsey }
        end

        context 'when alternative prep time is greater than twice advocacy' do
          let(:prosecution_evidence) { 11 }

          it { expect(subject.assess).to be_falsey }
        end
      end
    end
  end
end
