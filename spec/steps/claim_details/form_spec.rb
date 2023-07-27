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

  describe '#save preparation time yes' do
    context 'when all fields are set and preparation_time set to yes' do
      let(:preparation_time) { 'yes' }

      it 'is valid' do
        expect(subject.save).to be_truthy
        expect(application).to have_received(:update!)
        expect(subject).to be_valid
      end
    end
  end

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

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'when work before is valid' do
        let(:work_before) { nil }

        it 'is is valid' do
          expect(subject.save).to be_truthy
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

        it { expect(subject).to be_valid }
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

  describe '#preparation_time' do
    context 'when preparation_time is passed in as yes' do
      it { expect(subject.preparation_time).to eq(YesNoAnswer::YES) }
    end

    context 'when preparation_time is passed in as no' do
      let(:preparation_time) { 'no' }

      it { expect(subject.preparation_time).to eq(YesNoAnswer::NO) }
    end

    context 'when preparation_time is not passed in' do
      let(:preparation_time) { nil }

      context 'when time_spent is set' do
        let(:time_spent) { 100 }

        it { expect(subject.preparation_time).to eq(YesNoAnswer::YES) }
      end

      context 'when time_spent is not set' do
        let(:time_spent) { nil }

        it { expect(subject.preparation_time).to be_nil }
      end
    end
  end

  describe '#work_before' do
    context 'when work_before is passed in as yes' do
      it { expect(subject.work_before).to eq(YesNoAnswer::YES) }
    end

    context 'when work_before is passed in as no' do
      let(:work_before) { 'no' }

      it { expect(subject.work_before).to eq(YesNoAnswer::NO) }
    end

    context 'when work_before is not passed in' do
      let(:work_before) { nil }

      context 'when work_before_date is set' do
        let(:work_before_date) { Date.yesterday }

        it { expect(subject.work_before).to eq(YesNoAnswer::YES) }
      end

      context 'when work_before_date is not set' do
        let(:work_before_date) { nil }

        it { expect(subject.work_before).to be_nil }
      end
    end
  end

  describe '#work_after' do
    context 'when work_after is passed in as yes' do
      it { expect(subject.work_after).to eq(YesNoAnswer::YES) }
    end

    context 'when work_after is passed in as no' do
      let(:work_after) { 'no' }

      it { expect(subject.work_after).to eq(YesNoAnswer::NO) }
    end

    context 'when work_after is not passed in' do
      let(:work_after) { nil }

      context 'when work_after_date is set' do
        let(:work_after_date) { Date.yesterday }

        it { expect(subject.work_after).to eq(YesNoAnswer::YES) }
      end

      context 'when work_after_date is not set' do
        let(:work_after_date) { nil }

        it { expect(subject.work_after).to be_nil }
      end
    end
  end
end
