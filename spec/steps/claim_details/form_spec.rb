require 'rails_helper'

RSpec.describe Steps::ClaimDetailsForm do
  subject { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      application:,
      prosecution_evidence:,
      defence_statement:,
      number_of_witnesses:,
      supplemental_claim:,
      preparation_time:,
      time_spent:,
      work_before_date:,
      work_after_date:,
    }
  end

  let(:application) { instance_double(Claim, update!: true) }

  let(:prosecution_evidence) { 'prosection evidence' }
  let(:defence_statement) { 'defence statement' }
  let(:number_of_witnesses) { 1 }
  let(:supplemental_claim) { 'yes' }
  let(:preparation_time) { 'yes' }
  let(:work_before) { 'yes' }
  let(:work_after) { 'yes' }
  let(:time_spent) { { 1 => hours, 2 => minutes } }
  let(:hours) { 2 }
  let(:minutes) { 40 }

  describe '#save preparation time yes' do
    context 'when all fields are set and preparation_time set to yes' do
      let(:preparation_time) { 'yes' }
      let(:time_spent_hours) { 2 }
      let(:time_spent_mins) { 40 }
      let(:work_before_date) { Date.new(2023, 1, 1) }
      let(:work_after_date) { Date.new(2023, 1, 1) }

      it 'is not valid' do
        expect(subject.save).to be_truthy
        expect(application).to have_received(:update!)
        expect(subject).to be_valid
      end
    end
  end

  describe '#save' do
    let(:application) { Claim.create(office_code: 'AAA', time_spent: time_spent_in_db) }
    let(:time_spent_in_db) { nil }

    context 'when preparation is yes' do
      let(:preparation_time) { 'yes' }
      let(:work_before_date) { Date.new(2023, 1, 1) }
      let(:work_after_date) { Date.new(2023, 1, 1) }

      context 'when time_spent is valid' do
        it 'is updated the DB in minutes' do
          expect(subject.save).to be_truthy
          expect(application.reload).to have_attributes(
            time_spent: 160
          )
        end
      end
    end

    context 'when preparation is no' do
      let(:preparation_time) { 'no' }

      context 'time_spent has a value in the database' do
        let(:time_spent_in_db) { 100 }
        let(:work_before_date) { Date.new(2023, 1, 1) }
        let(:work_after_date) { Date.new(2023, 1, 1) }

        it 'clears the database field' do
          expect(subject.save).to be_truthy
          expect(application.reload).to have_attributes(
            time_spent: 160
          )
        end
      end
    end
  end

  describe '#preparation is valid?' do
    context 'when preparation is yes' do
      let(:preparation_time) { 'yes' }
      let(:work_before_date) { Date.new(2023, 1, 1) }
      let(:work_after_date) { Date.new(2023, 1, 1) }

      context 'when all fields are set' do
        it { expect(subject).to be_valid }
      end

      context 'when hours is blank' do
        let(:hours) { nil }
        let(:minutes) { nil }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:time_spent, :blank_hours)).to be(true)
        end
      end
    end

    context 'when preparation is no' do
      let(:preparation_time) { 'no' }
      let(:work_before_date) { Date.new(2023, 1, 1) }
      let(:work_after_date) { Date.new(2023, 1, 1) }

      context 'when all fields are set' do
        it { expect(subject).to be_valid }
      end

      context 'when hours is blank' do
        let(:hours) { nil }

        it { expect(subject).to be_valid }
      end
    end
  end

  context 'when work_before is yes' do
    let(:work_before) { 'yes' }
    let(:work_after_date) { Date.new(2023, 1, 1) }
    let(:work_before_date) { Date.new(2023, 1, 1) }

    context 'when all fields are set' do
      it { expect(subject).to be_valid }
    end

    context 'when work_before_date is blank' do
      let(:work_before_date) { nil }

      it { expect(subject).to be_valid }
    end
  end

  context 'when work_after is yes' do
    let(:work_after) { 'yes' }
    let(:work_before_date) { Date.new(2023, 1, 1) }
    let(:work_after_date) { Date.new(2023, 1, 1) }

    context 'when work_after_date is blank' do
      it { expect(subject).to be_valid }
    end
  end
end
