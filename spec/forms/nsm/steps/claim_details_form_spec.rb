require 'rails_helper'

RSpec.describe Nsm::Steps::ClaimDetailsForm do
  subject(:form) { described_class.new(application:, **arguments) }

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
      work_completed_date:,
      wasted_costs:,
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
  let(:work_completed_date) { Date.yesterday }
  let(:time_spent) { { 1 => hours, 2 => minutes } }
  let(:hours) { 2 }
  let(:minutes) { 40 }
  let(:wasted_costs) { 'yes' }

  describe '#save' do
    let(:application) do
      create(:claim, time_spent: time_spent_in_db, work_before_date: work_before_date_in_db,
     work_after_date: work_after_date_in_db, work_completed_date: work_completed_date_in_db)
    end
    let(:time_spent_in_db) { nil }
    let(:work_before_date_in_db) { nil }
    let(:work_after_date_in_db) { nil }
    let(:work_completed_date_in_db) { nil }

    context 'when values are yes' do
      let(:preparation_time) { 'yes' }
      let(:work_before) { 'yes' }
      let(:work_after) { 'yes' }

      it 'is stores the values in the database' do
        expect(form.save).to be_truthy
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
          expect(form.save).to be_truthy
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
    context 'with nil boolean fields' do
      let(:supplemental_claim) { nil }
      let(:preparation_time) { nil }
      let(:work_before) { nil }
      let(:work_after) { nil }
      let(:wasted_costs) { nil }
      let(:work_completed_date) { nil }

      it 'they must be present' do
        expect(form).not_to be_valid
        expect(form.errors).to include(:supplemental_claim, :preparation_time, :work_before, :work_after, :wasted_costs,
                                       :work_completed_date)
      end
    end

    context 'with invalid value boolean fields' do
      let(:supplemental_claim) { 1 }
      let(:preparation_time) { 'y' }
      let(:work_before) { true }
      let(:work_after) { false }
      let(:wasted_costs) { 'f' }

      it 'they can only be yes or no' do
        expect(form).not_to be_valid
        expect(form.errors).to include(:supplemental_claim, :preparation_time, :work_before, :work_after, :wasted_costs)
      end
    end

    context 'with valid value boolean fields' do
      let(:supplemental_claim) { 'yes' }
      let(:preparation_time) { 'yes' }
      let(:work_before) { 'no' }
      let(:work_after) { 'no' }
      let(:wasted_costs) { 'no' }

      it 'they can only be yes or no' do
        expect(form).to be_valid
      end
    end

    context 'work_before_date' do
      context 'and work_before is nil' do
        let(:work_before) { nil }

        it 'is not valid' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:work_before, :inclusion)).to be(true)
        end
      end

      context 'and work_before is no' do
        let(:work_before) { 'no' }

        it { expect(form).to be_valid }
      end

      context 'and work_before is yes' do
        let(:work_before) { 'yes' }
        let(:work_before_date) { nil }

        it 'is not valid' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:work_before_date, :blank)).to be(true)
        end
      end
    end

    context 'work_after_date' do
      context 'and work_after is nil' do
        let(:work_after) { nil }

        it 'is invalid' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:work_after, :inclusion)).to be(true)
        end
      end

      context 'and work_after is no' do
        let(:work_after) { 'no' }

        it { expect(form).to be_valid }
      end

      context 'and work_after is yes' do
        let(:work_after) { 'yes' }
        let(:work_after_date) { nil }

        it 'is not valid' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:work_after_date, :blank)).to be(true)
        end
      end
    end
  end
end
