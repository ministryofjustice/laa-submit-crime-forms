require 'rails_helper'

RSpec.describe Nsm::Steps::ClaimDetailsForm do
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
      work_before:,
      work_after:,
      work_before_date:,
      work_after_date:,
    }
  end

  let(:application) { instance_double(Claim, update!: true) }

  let(:prosecution_evidence) { 1 }
  let(:defence_statement) { 2 }
  let(:number_of_witnesses) { 3 }
  let(:supplemental_claim) { 'yes' }
  let(:preparation_time) { 'yes' }
  let(:work_before) { 'yes' }
  let(:work_after) { 'yes' }
  let(:work_before_date) { Date.yesterday }
  let(:work_after_date) { Date.yesterday }
  let(:time_spent) { { 1 => hours, 2 => minutes } }
  let(:hours) { 2 }
  let(:minutes) { 40 }

  describe '#save' do
    let(:application) do
      create(:claim, time_spent: time_spent_in_db, work_before_date: work_before_date_in_db,
     work_after_date: work_after_date_in_db)
    end
    let(:time_spent_in_db) { nil }
    let(:work_before_date_in_db) { nil }
    let(:work_after_date_in_db) { nil }

    context 'when values are yes' do
      let(:preparation_time) { 'yes' }
      let(:work_before) { 'yes' }
      let(:work_after) { 'yes' }

      it 'is stores the values in the database' do
        expect(subject.save).to be_truthy
        expect(application.reload).to have_attributes(
          time_spent: 160
        )
      end
    end

    context 'when values are no' do
      let(:preparation_time) { 'no' }
      let(:work_before) { 'no' }
      let(:work_after) { 'no' }

      context 'time_spent has a value in the database' do
        let(:time_spent_in_db) { 100 }
        let(:work_before_date_in_db) { Date.yesterday }
        let(:work_after_date_in_db) { Date.yesterday }

        it 'clears the database field' do
          expect(subject.save).to be_truthy
          expect(application.reload).to have_attributes(
            time_spent: nil,
            work_before_date: nil,
            work_after_date: nil,
          )
        end
      end
    end
  end

  describe '#validations' do
    context 'work_before_date' do
      context 'and work_before is nil' do
        let(:work_before) { nil }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:work_before, :inclusion)).to be(true)
        end
      end

      context 'and work_before is no' do
        let(:work_before) { 'no' }

        it { expect(subject).to be_valid }
      end

      context 'and work_before is yes' do
        let(:work_before) { 'yes' }
        let(:work_before_date) { nil }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:work_before_date, :blank)).to be(true)
        end
      end
    end

    context 'work_after_date' do
      context 'and work_after is nil' do
        let(:work_after) { nil }

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:work_after, :inclusion)).to be(true)
        end
      end

      context 'and work_after is no' do
        let(:work_after) { 'no' }

        it { expect(subject).to be_valid }
      end

      context 'and work_after is yes' do
        let(:work_after) { 'yes' }
        let(:work_after_date) { nil }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:work_after_date, :blank)).to be(true)
        end
      end
    end
  end
end
