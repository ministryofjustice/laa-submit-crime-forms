require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::CostSummaryCard do
  subject { described_class.new(claim) }

  let(:claim) do
    build(
      :claim,
      work_items:,
      disbursements:,
      firm_office:,
      letters:,
      calls:
    )
  end
  let(:firm_office) { build(:firm_office, vat_registered:) }
  let(:vat_registered) { 'no' }
  let(:disbursements) { [] }
  let(:work_items) { [] }
  let(:letters) { nil }
  let(:calls) { nil }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Cost summary')
    end
  end

  describe '#headers' do
    context 'when show_adjustments is not passed in' do
      it 'retruns the translated headers' do
        expect(subject.headers).to eq(
          [
            { numeric: false, text: '', width: 'govuk-!-width-one-quarter' },
            { numeric: true, text: 'Net cost', width: nil },
            { numeric: true, text: 'VAT', width: nil },
            { numeric: true, text: 'Total', width: nil },
            nil, nil, nil
          ]
        )
      end
    end

    context 'when show_adjustments is true' do
      subject { described_class.new(claim, show_adjustments: true) }

      it 'retruns the translated headers' do
        expect(subject.headers).to eq(
          [
            { numeric: false, text: '', width: 'govuk-!-width-one-quarter' },
            { numeric: true, text: 'Net cost claimed', width: nil },
            { numeric: true, text: 'VAT claimed', width: nil },
            { numeric: true, text: 'Total claimed', width: nil },
            { numeric: true, text: 'Net cost allowed', width: nil },
            { numeric: true, text: 'VAT allowed', width: nil },
            { numeric: true, text: 'Total allowed', width: nil }
          ]
        )
      end
    end
  end

  describe '#table_fields' do
    context 'when a single work item exists' do
      let(:work_items) do
        [build(:work_item, work_type: 'advocacy', time_spent: 600)]
      end

      context 'when show_adjustments is not passed in' do
        it 'sums them into profit costs' do
          expect(subject.table_fields[0]).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£654.20' }, name: { numeric: false, text: 'Profit costs', width: nil },
              net_cost: { numeric: true, text: '£654.20' }, vat: { numeric: true, text: '£0.00' }
            }
          )
        end
      end

      context 'when show_adjustments is true' do
        subject { described_class.new(claim, show_adjustments: true) }

        it 'sums them into profit costs' do
          expect(subject.table_fields[0]).to eq(
            {
              allowed_gross_cost: { numeric: true, text: '£654.20' },
              allowed_net_cost: { numeric: true, text: '£654.20' }, allowed_vat: { numeric: true, text: '£0.00' },
              gross_cost: { numeric: true, text: '£654.20' }, name: { numeric: false, text: 'Profit costs', width: nil },
              net_cost: { numeric: true, text: '£654.20' }, vat: { numeric: true, text: '£0.00' }
            }
          )
        end
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [
          build(:work_item, work_type: 'advocacy', time_spent: 600),
          build(:work_item, work_type: 'preparation', time_spent: 660)
        ]
      end

      context 'when show_adjustments is not passed in' do
        it 'summs them all together in profit costs' do
          expect(subject.table_fields[0]).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£1,227.85' }, name: { numeric: false, text: 'Profit costs', width: nil },
              net_cost: { numeric: true, text: '£1,227.85' }, vat: { numeric: true, text: '£0.00' }
            }
          )
        end
      end
    end

    context 'when waiting and travel work items exist' do
      let(:work_items) do
        [
          build(:work_item, work_type: 'travel', time_spent: 600),
          build(:work_item, work_type: 'waiting', time_spent: 600),
          build(:work_item, work_type: 'preparation', time_spent: 660)
        ]
      end

      context 'when show_adjustments is not passed in' do
        it 'they are returned' do
          expect(subject.table_fields[1]).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£276.00' },
              name: { numeric: false, text: 'Waiting', width: nil }, net_cost: { numeric: true, text: '£276.00' },
              vat: { numeric: true, text: '£0.00' }
            }
          )
          expect(subject.table_fields[2]).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£276.00' },
              name: { numeric: false, text: 'Travel', width: nil }, net_cost: { numeric: true, text: '£276.00' },
              vat: { numeric: true, text: '£0.00' }
            }
          )
        end
      end
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [
          build(:work_item, work_type: 'advocacy', time_spent: 600),
          build(:work_item, work_type: 'advocacy', time_spent: 660)
        ]
      end

      context 'when show_adjustments is not passed in' do
        it 'includes a summed table field row' do
          expect(subject.table_fields[0]).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£1,373.82' }, name: { numeric: false, text: 'Profit costs', width: nil },
              net_cost: { numeric: true, text: '£1,373.82' }, vat: { numeric: true, text: '£0.00' }
            }
          )
        end
      end
    end

    context 'when disbursements exists - with vat' do
      let(:disbursements) do
        [build(:disbursement, :valid, apply_vat: 'true', total_cost_without_vat: 600.0, disbursement_type: 'other')]
      end

      context 'when show_adjustments is not passed in' do
        it 'summs them all together in profit costs' do
          expect(subject.table_fields[3]).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£720.00' }, name: { numeric: false, text: 'Disbursements', width: nil },
              net_cost: { numeric: true, text: '£600.00' }, vat: { numeric: true, text: '£120.00' }
            }
          )
        end
      end
    end

    context 'when disbursements exists - without vat' do
      let(:disbursements) do
        [build(:disbursement, :valid, apply_vat: 'false', total_cost_without_vat: 600.0, disbursement_type: 'other')]
      end

      context 'when show_adjustments is not passed in' do
        it 'summs them all together in profit costs' do
          expect(subject.table_fields[3]).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£600.00' }, name: { numeric: false, text: 'Disbursements', width: nil },
              net_cost: { numeric: true, text: '£600.00' }, vat: { numeric: true, text: '£0.00' }
            }
          )
        end
      end
    end

    context 'when letters and calls exist' do
      let(:letters) { 10 }
      let(:calls) { 5 }

      it 'sums them into profit costs' do
        expect(subject.table_fields[0]).to eq(
          {
            allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
            gross_cost: { numeric: true, text: '£61.35' },
            name: { numeric: false, text: 'Profit costs', width: nil },
            net_cost: { numeric: true, text: '£61.35' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end
  end

  describe '#summed_fields' do
    context 'when a single work item exists' do
      let(:work_items) do
        [build(:work_item, work_type: 'advocacy', time_spent: 600)]
      end

      context 'when show_adjustments is not passed in' do
        it 'returns the summed cost' do
          expect(subject.summed_fields).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£654.20' },
              name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£654.20' },
              vat: { numeric: true, text: '£0.00' }
            }
          )
        end
      end

      context 'when show_adjustments is true' do
        subject { described_class.new(claim, show_adjustments: true) }

        it 'returns the summed cost' do
          expect(subject.summed_fields).to eq(
            {
              allowed_gross_cost: { numeric: true, text: '£654.20' }, allowed_net_cost: { numeric: true, text: '£654.20' },
              allowed_vat: { numeric: true, text: '£0.00' },
              gross_cost: { numeric: true, text: '£654.20' },
              name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£654.20' },
              vat: { numeric: true, text: '£0.00' }
            }
          )
        end
      end
    end

    context 'when firm is VAT registered' do
      let(:vat_registered) { 'yes' }
      let(:work_items) do
        [build(:work_item, work_type: 'advocacy', time_spent: 600)]
      end

      context 'when show_adjustments is not passed in' do
        it 'returns the summed time and cost' do
          expect(subject.summed_fields).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£785.04' },
              name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£654.20' },
              vat: { numeric: true, text: '£130.84' }
            }
          )
        end
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [
          build(:work_item, work_type: 'advocacy', time_spent: 600),
          build(:work_item, work_type: 'travel', time_spent: 600)
        ]
      end

      context 'when show_adjustments is not passed in' do
        it 'returns the summed cost' do
          expect(subject.summed_fields).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£930.20' },
              name: { numeric: false, text: 'Total', width: nil }, net_cost: { numeric: true, text: '£930.20' },
              vat: { numeric: true, text: '£0.00' }
            }
          )
        end
      end
    end

    context 'when letters and calls exist' do
      let(:letters) { 10 }
      let(:calls) { 5 }

      it 'returns the summed cost' do
        expect(subject.summed_fields).to eq(
          {
            allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
            gross_cost: { numeric: true, text: '£61.35' },
            name: { numeric: false, text: 'Total', width: nil },
            net_cost: { numeric: true, text: '£61.35' },
            vat: { numeric: true, text: '£0.00' }
          }
        )
      end
    end

    context 'when disbursements exists' do
      let(:disbursements) do
        [build(:disbursement, :valid, apply_vat: 'true', total_cost_without_vat: 600.0, disbursement_type: 'other')]
      end

      context 'when show_adjustments is not passed in' do
        it 'summs them all together in profit costs' do
          expect(subject.table_fields[3]).to eq(
            {
              allowed_gross_cost: nil, allowed_net_cost: nil, allowed_vat: nil,
              gross_cost: { numeric: true, text: '£720.00' }, name: { numeric: false, text: 'Disbursements', width: nil },
              net_cost: { numeric: true, text: '£600.00' }, vat: { numeric: true, text: '£120.00' }
            }
          )
        end
      end
    end
  end
end
