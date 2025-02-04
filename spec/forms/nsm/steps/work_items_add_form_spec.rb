require 'rails_helper'

RSpec.describe Nsm::Steps::WorkItemForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      record:,
      work_type:,
      time_spent:,
      completed_on:,
      fee_earner:,
      apply_uplift:,
      uplift:,
      add_another:,
    }
  end

  let(:application) do
    create :claim, :firm_details, work_items: work_items, claim_type: 'breach_of_injunction',
                    cntp_date: date, assigned_counsel: assigned_counsel,
                    reasons_for_claim: reasons_for_claim
  end
  let(:work_items) { [build(:work_item), record] }
  let(:date) { Date.new(2023, 1, 1) }
  let(:record) { build(:work_item) }
  let(:work_type) { WorkTypes.values.sample.to_s }
  let(:time_spent) { { 1 => hours, 2 => minutes } }
  let(:hours) { 1 }
  let(:minutes) { 1 }
  let(:completed_on) { Date.new(2023, 3, 1) }
  let(:fee_earner) { 'JBJ' }
  let(:apply_uplift) { 'true' }
  let(:uplift) { 10 }
  let(:assigned_counsel) { 'yes' }
  let(:reasons_for_claim) { [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s] }
  let(:add_another) { 'yes' }

  describe '#validations' do
    context 'require fields' do
      %w[work_type time_spent completed_on fee_earner add_another].each do |field|
        describe "#when #{field} is blank" do
          let(field) { nil }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(field, :blank)).to be(true)
          end
        end
      end

      %w[hours minutes].each do |field|
        describe "#when #{field} is blank" do
          let(field) { nil }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:time_spent, :"blank_#{field}")).to be(true)
          end
        end
      end
    end

    describe '#uplift' do
      context 'when apply_uplift is true' do
        context 'is negative' do
          let(:uplift) { -1 }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:uplift, :greater_than_or_equal_to)).to be(true)
          end
        end

        context 'is blank' do
          let(:uplift) { '' }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:uplift, :blank)).to be(true)
          end
        end

        context 'is zero' do
          let(:uplift) { 0 }

          it { expect(subject).not_to be_valid }
        end

        context 'is positive' do
          let(:uplift) { 1 }

          it { expect(subject).to be_valid }
        end

        context 'is 100' do
          let(:uplift) { 100 }

          it { expect(subject).to be_valid }
        end

        context 'is over 100' do
          let(:uplift) { 101 }

          it 'have an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:uplift, :less_than_or_equal_to)).to be(true)
          end
        end

        context 'is not an integer-y string' do
          let(:uplift) { '1.6' }

          it 'does not modify the invalid value' do
            expect(subject).not_to be_valid
            expect(subject.uplift).to eq('1.6')
          end
        end
      end

      context 'when apply_uplift is falsey' do
        let(:apply_uplift) { 'false' }

        context 'is negative' do
          let(:uplift) { -1 }

          it { expect(subject).to be_valid }
        end
      end
    end

    describe 'invalid work item type given prog/prom' do
      let(:work_type) { WorkTypes::TRAVEL }

      before do
        application.update(claim_type: 'non_standard_magistrate', office_in_undesignated_area: false, rep_order_date: date)
      end

      it 'has an error' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:work_type, :inclusion)).to be(true)
      end
    end
  end

  describe '#allow_uplift?' do
    context 'when reasons_for_claim contains ENHANCED_RATES_CLAIMED' do
      it { expect(subject).to be_allow_uplift }
    end

    context 'when reasons_for_claim does not contain ENHANCED_RATES_CLAIMED' do
      let(:reasons_for_claim) { ['other'] }

      it { expect(subject).not_to be_allow_uplift }
    end
  end

  describe '#apply_uplift' do
    context 'when reasons_for_claim contains ENHANCED_RATES_CLAIMED' do
      context 'when set to nil - not set' do
        let(:apply_uplift) { nil }

        context 'and letters_calls_uplift is not nil' do
          let(:uplift) { 10 }

          it { expect(subject.apply_uplift).to be_truthy }
        end

        context 'and letters_calls_uplift is zero' do
          let(:uplift) { 0 }

          it { expect(subject.apply_uplift).to be_falsey }
        end

        context 'and letters_calls_uplift is nil' do
          let(:uplift) { nil }

          it { expect(subject.apply_uplift).to be_falsey }
        end
      end

      context 'when set to "true"' do
        let(:apply_uplift) { 'true' }

        it { expect(subject.apply_uplift).to be_truthy }
      end

      context 'when set to "false"' do
        let(:apply_uplift) { 'false' }

        it { expect(subject.apply_uplift).to be_falsey }
      end
    end

    context 'when reasons_for_claim does not contain ENHANCED_RATES_CLAIMED' do
      let(:reasons_for_claim) { ['other'] }

      it { expect(subject.apply_uplift).to be_falsey }
    end
  end

  describe '#total_costs' do
    let(:price) { application.rates.work_items[work_type.to_sym] }

    it 'is equal to hours and minutes * the price for the work type * uplift' do
      expect(subject.total_cost).to be_within(0.0001).of((61.0 * (price / 60) * 1.1).round(2))
    end

    context 'when apply uplift is no' do
      let(:apply_uplift) { false }

      it 'is equal to hours and minutes * the price for the work type' do
        expect(subject.total_cost).to be_within(0.0001).of((61.0 * price / 60).round(2))
      end
    end

    context 'when uplift is not set' do
      let(:uplift) { nil }

      it 'is equal to hours and minutes * the price for the work type' do
        expect(subject.total_cost).to be_within(0.0001).of((61.0 * price / 60).round(2))
      end
    end

    context 'when hours is nil' do
      let(:hours) { nil }

      it 'can not calculate a price' do
        expect(subject.total_cost).to be_nil
      end
    end

    context 'when minutes is nil' do
      let(:minutes) { nil }

      it 'can not calculate a price' do
        expect(subject.total_cost).to be_nil
      end
    end
  end

  describe '#work_types_with_pricing' do
    context 'when application date is before CLAIR' do
      let(:date) { Date.new(2022, 1, 1) }

      it 'uses the old prices' do
        expect(subject.work_types_with_pricing).to eq([
                                                        [WorkTypes::ATTENDANCE_WITH_COUNSEL, 31.03],
                                                        [WorkTypes::ATTENDANCE_WITHOUT_COUNSEL, 45.35],
                                                        [WorkTypes::PREPARATION, 45.35],
                                                        [WorkTypes::ADVOCACY, 56.89],
                                                        [WorkTypes::TRAVEL, 24.0],
                                                        [WorkTypes::WAITING, 24.0],
                                                      ])
      end

      context 'when assigned_councel is no' do
        let(:assigned_counsel) { 'no' }

        it 'does not include ATTENDANCE_WITH_COUNSEL' do
          expect(subject.work_types_with_pricing).to eq([
                                                          [WorkTypes::ATTENDANCE_WITHOUT_COUNSEL, 45.35],
                                                          [WorkTypes::PREPARATION, 45.35],
                                                          [WorkTypes::ADVOCACY, 56.89],
                                                          [WorkTypes::TRAVEL, 24.0],
                                                          [WorkTypes::WAITING, 24.0],
                                                        ])
        end
      end

      context 'when prog stage not reached' do
        before do
          application.update(claim_type: 'non_standard_magistrate', office_in_undesignated_area: false, rep_order_date: date)
        end

        it 'does not include TRAVEL or WAITING' do
          expect(subject.work_types_with_pricing).to eq([
                                                          [WorkTypes::ATTENDANCE_WITH_COUNSEL, 31.03],
                                                          [WorkTypes::ATTENDANCE_WITHOUT_COUNSEL, 45.35],
                                                          [WorkTypes::PREPARATION, 45.35],
                                                          [WorkTypes::ADVOCACY, 56.89],
                                                        ])
        end
      end
    end

    context 'when application date is after CLAIR' do
      it 'uses the new prices' do
        expect(subject.work_types_with_pricing).to eq([
                                                        [WorkTypes::ATTENDANCE_WITH_COUNSEL, 35.68],
                                                        [WorkTypes::ATTENDANCE_WITHOUT_COUNSEL, 52.15],
                                                        [WorkTypes::PREPARATION, 52.15],
                                                        [WorkTypes::ADVOCACY, 65.42],
                                                        [WorkTypes::TRAVEL, 27.6],
                                                        [WorkTypes::WAITING, 27.6],
                                                      ])
      end

      context 'when assigned_councel is no' do
        let(:assigned_counsel) { 'no' }

        it 'does not include ATTENDANCE_WITH_COUNSEL' do
          expect(subject.work_types_with_pricing).to eq([
                                                          [WorkTypes::ATTENDANCE_WITHOUT_COUNSEL, 52.15],
                                                          [WorkTypes::PREPARATION, 52.15],
                                                          [WorkTypes::ADVOCACY, 65.42],
                                                          [WorkTypes::TRAVEL, 27.6],
                                                          [WorkTypes::WAITING, 27.6],
                                                        ])
        end
      end

      context 'when prog stage not reached' do
        before do
          application.update(claim_type: 'non_standard_magistrate', office_in_undesignated_area: false, rep_order_date: date)
        end

        it 'does not include TRAVEL or WAITING' do
          expect(subject.work_types_with_pricing).to eq([
                                                          [WorkTypes::ATTENDANCE_WITH_COUNSEL, 35.68],
                                                          [WorkTypes::ATTENDANCE_WITHOUT_COUNSEL, 52.15],
                                                          [WorkTypes::PREPARATION, 52.15],
                                                          [WorkTypes::ADVOCACY, 65.42],
                                                        ])
        end
      end
    end
  end

  describe 'calculation_rows' do
    let(:work_type) { WorkTypes::ATTENDANCE_WITH_COUNSEL.to_s }

    context 'when values are nil' do
      let(:time_spent) { nil }

      it 'returns 0 values' do
        expect(subject.calculation_rows).to eq(
          [['Net cost claimed', 'Net cost with uplift'],
           [{ html_attributes: { id: 'without-uplift' }, text: '£' },
            { html_attributes: { id: 'with-uplift' }, text: '£' }]]
        )
      end
    end

    context 'when values are non-nil' do
      let(:time_spent) { { 1 => '1', 2 => '30' } }

      context 'when uplift is not required' do
        let(:reasons_for_claim) { [ReasonForClaim::REPRESENTATION_ORDER_WITHDRAWN.to_s] }

        it 'returns the values' do
          expect(subject.calculation_rows).to eq(
            [['Net cost claimed'],
             [{ html_attributes: { id: 'without-uplift' }, text: '£53.52' }]]
          )
        end
      end

      context 'when uplift is required but values are not set' do
        let(:uplift) { nil }

        it 'returns the values' do
          expect(subject.calculation_rows).to eq(
            [['Net cost claimed', 'Net cost with uplift'],
             [{ html_attributes: { id: 'without-uplift' }, text: '£53.52' },
              { html_attributes: { id: 'with-uplift' }, text: '£53.52' }]]
          )
        end
      end

      context 'when uplift is required and values are set' do
        it 'returns the values' do
          expect(subject.calculation_rows).to eq(
            [['Net cost claimed', 'Net cost with uplift'],
             [{ html_attributes: { id: 'without-uplift' }, text: '£53.52' },
              { html_attributes: { id: 'with-uplift' }, text: '£58.87' }]]
          )
        end
      end
    end
  end

  describe 'save!' do
    let(:application) do
      create(:claim, reasons_for_claim: [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s])
    end
    let(:record) { WorkItem.create!(uplift: 40, claim: application) }

    context 'when uplift exists in DB but apply_uplift is false in attributes' do
      let(:apply_uplift) { 'false' }

      it 'resets the uplift value' do
        subject.save!
        expect(record.reload).to have_attributes(
          uplift: 0
        )
      end
    end

    context 'when apply_lift is true and uplift value exists' do
      it 'sets the uplift value' do
        subject.save!
        expect(record.reload).to have_attributes(
          uplift: 10
        )
      end
    end
  end
end
