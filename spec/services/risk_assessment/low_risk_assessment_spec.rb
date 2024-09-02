# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RiskAssessment::LowRiskAssessment do
  subject { described_class.new(claim) }

  let(:claim) { create(:claim, work_items:, prosecution_evidence:, defence_statement:, time_spent:, number_of_witnesses:) }
  let(:work_items) { [attendance_work_item, advocacy_work_item, preparation_work_item] }
  let(:attendance_work_item) { build(:work_item, work_type: 'attendance_with_counsel', time_spent: attendance_time_spent) }
  let(:preparation_work_item) { build(:work_item, work_type: 'preparation', time_spent: preparation_time_spent) }
  let(:advocacy_work_item) { build(:work_item, work_type: 'advocacy', time_spent: advocacy_time_spent) }
  let(:attendance_time_spent) { nil }
  let(:advocacy_time_spent) { nil }
  let(:preparation_time_spent) { nil }
  let(:prosecution_evidence) { nil }
  let(:defence_statement) { nil }
  let(:time_spent) { nil }
  let(:number_of_witnesses) { nil }

  describe '#assess' do
    context 'when raw prep time is less than twice advocacy' do
      let(:preparation_time_spent) { 39 }
      let(:advocacy_time_spent) { 20 }

      context 'when attendance is less than twice advocacy' do
        let(:attendance_time_spent) { 39 }

        it { expect(subject.assess).to be_truthy }
      end

      context 'when attendance is equal to twice advocacy' do
        let(:attendance_time_spent) { 40 }

        it { expect(subject.assess).to be_truthy }
      end

      context 'when attendance is more than twice advocacy' do
        let(:attendance_time_spent) { 41 }

        it { expect(subject.assess).to be_falsey }
      end
    end

    context 'when raw prep time is equal to twice advocacy' do
      let(:preparation_time_spent) { 40 }
      let(:advocacy_time_spent) { 20 }

      context 'when attendance is less than twice advocacy' do
        let(:attendance_time_spent) { 39 }

        it { expect(subject.assess).to be_truthy }
      end

      context 'when attendance is equal to twice advocacy' do
        let(:attendance_time_spent) { 40 }

        it { expect(subject.assess).to be_truthy }
      end

      context 'when attendance is more than twice advocacy' do
        let(:attendance_time_spent) { 41 }

        it { expect(subject.assess).to be_falsey }
      end
    end

    context 'when raw prep time is greater than advocacy' do
      let(:preparation_time_spent) { 80 }
      let(:advocacy_time_spent) { 20 }

      context 'when attendance is less than twice advocacy' do
        let(:attendance_time_spent) { 39 }

        context 'when prosecution evidence allowance brings prep time down to below twice advocacy' do
          let(:prosecution_evidence) { 21 }

          it { expect(subject.assess).to be_truthy }
        end

        context 'when prosecution evidence allowance brings prep time down to exactly twice advocacy' do
          let(:prosecution_evidence) { 20 }

          it { expect(subject.assess).to be_truthy }
        end

        context 'when prosecution evidence is not enough to bring prep time down to below twice advocacy' do
          let(:prosecution_evidence) { 19 }

          it { expect(subject.assess).to be_falsey }
        end

        context 'when defence statement allowance brings prep time down to below twice advocacy' do
          let(:defence_statement) { 21 }

          it { expect(subject.assess).to be_truthy }
        end

        context 'when defence statement is not enough to bring prep time down to below twice advocacy' do
          let(:defence_statement) { 19 }

          it { expect(subject.assess).to be_falsey }
        end

        context 'when video allowance brings prep time down to below twice advocacy' do
          let(:time_spent) { 21 }

          it { expect(subject.assess).to be_truthy }
        end

        context 'when video is not enough to bring prep time down to below twice advocacy' do
          let(:time_spent) { 19 }

          it { expect(subject.assess).to be_falsey }
        end

        context 'when witness allowance brings prep time down to below twice advocacy' do
          let(:number_of_witnesses) { 2 }

          it { expect(subject.assess).to be_truthy }
        end

        context 'when witness is not enough to bring prep time down to below twice advocacy' do
          let(:number_of_witnesses) { 1 }

          it { expect(subject.assess).to be_falsey }
        end

        context 'when multiple allowances bring prep time down to below twice advocacy' do
          let(:number_of_witnesses) { 1 } # 30 minute allowance
          let(:time_spent) { 2 } # 4 minute allowance
          let(:defence_statement) { 2 } # 4 minute allowance
          let(:prosecution_evidence) { 2 } # 4 minute allowance
          # 42 minutes of allowances subtracted from 80 minutes of preparation time,
          # should be less than 2 * 20 minutes of advocacy

          it { expect(subject.assess).to be_truthy }
        end
      end

      context 'when attendance is equal to twice advocacy' do
        let(:attendance_time_spent) { 40 }

        context 'when allowances bring prep time to less than twice advocacy' do
          let(:prosecution_evidence) { 21 }

          it { expect(subject.assess).to be_truthy }
        end

        context 'when allowances bring prep time to exactly twice advocacy' do
          let(:prosecution_evidence) { 20 }

          it { expect(subject.assess).to be_truthy }
        end

        context 'when allowances leave prep time greater than twice advocacy' do
          let(:prosecution_evidence) { 19 }

          it { expect(subject.assess).to be_falsey }
        end
      end

      context 'when attendance is more than twice advocacy' do
        let(:attendance_time_spent) { 41 }

        context 'when allowances bring prep time to less than twice advocacy' do
          let(:prosecution_evidence) { 21 }

          it { expect(subject.assess).to be_falsey }
        end

        context 'when allowances bring prep time to exactly twice advocacy' do
          let(:prosecution_evidence) { 20 }

          it { expect(subject.assess).to be_falsey }
        end

        context 'when allowances leave prep time greater than twice advocacy' do
          let(:prosecution_evidence) { 19 }

          it { expect(subject.assess).to be_falsey }
        end
      end
    end
  end
end
