require 'rails_helper'

RSpec.describe Nsm::AllowedWorkItems::SummaryTable do
  subject { described_class.new(work_items, skip_links:) }

  let(:work_items) { [work_item] }
  let(:skip_links) { false }
  let(:work_item) { create(:work_item, work_type: 'advocacy', time_spent: 100, claim: create(:claim)) }

  describe '#rows' do
    it 'has a row for each work item type' do
      expect(subject.rows.map { _1[0][:text] }).to eq(
        ['Travel', 'Waiting', 'Attendance with counsel', 'Attendance without counsel', 'Preparation', 'Advocacy']
      )
    end

    it 'shows work item details in the relevant row' do
      expect(subject.rows).to include(
        [
          { text: 'Advocacy', width: 'govuk-!-width-one-quarter' },
          { numeric: true,
            text: '1<span class="govuk-visually-hidden"> hour</span>:40<span class="govuk-visually-hidden"> minutes</span>' },
          { numeric: true, text: '£109.03' },
          { numeric: true,
            text:  '1<span class="govuk-visually-hidden"> hour</span>:40<span class="govuk-visually-hidden"> minutes</span>' },
          { numeric: true, text: '£109.03' }
        ]
      )
    end

    context 'when a work item has changed type' do
      let(:work_item) do
        create(:work_item,
               work_type: 'advocacy',
               allowed_work_type: 'travel',
               adjustment_comment: 'wrong type',
               time_spent: 100,
               claim: create(:claim))
      end

      it 'shows the relevant details in the row for the old type' do
        expect(subject.rows).to include(
          [
            { text: '<span title="One or more of these items were adjusted to be a different work item type.">Advocacy</span> ' \
                    '<sup><a href="#fn*">[*]</a></sup>',
              width: 'govuk-!-width-one-quarter' },
            { numeric: true,
              text: '1<span class="govuk-visually-hidden"> hour</span>:40<span class="govuk-visually-hidden"> minutes</span>' },
            { numeric: true, text: '£109.03' },
            { numeric: true,
              text: '0<span class="govuk-visually-hidden"> hours</span>:00<span class="govuk-visually-hidden"> minutes</span>' },
            { numeric: true, text: '£0.00' }
          ]
        )
      end

      context 'when skipping links' do
        let(:skip_links) { true }

        it 'shows appropriate text' do
          expect(subject.rows.last.first[:text]).to eq(
            '<span title="One or more of these items were adjusted to be a different work item type.">Advocacy</span> ' \
            '<sup>[*]</sup>'
          )
        end
      end

      it 'shows the relevant details in the row for the new type' do
        expect(subject.rows).to include(
          [
            { text: 'Travel', width: 'govuk-!-width-one-quarter' },
            { numeric: true,
              text: '0<span class="govuk-visually-hidden"> hours</span>:00<span class="govuk-visually-hidden"> minutes</span>' },
            { numeric: true, text: '£0.00' },
            { numeric: true,
              text: '1<span class="govuk-visually-hidden"> hour</span>:40<span class="govuk-visually-hidden"> minutes</span>' },
            { numeric: true, text: '£46.00' }
          ]
        )
      end
    end
  end
end
