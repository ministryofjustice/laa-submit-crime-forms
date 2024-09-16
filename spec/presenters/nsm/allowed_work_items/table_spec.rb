require 'rails_helper'

RSpec.describe Nsm::AllowedWorkItems::Table do
  subject { described_class.new(work_items, skip_links:) }

  let(:work_items) { [work_item] }
  let(:work_item) { create(:work_item, work_type: 'advocacy', time_spent: 100, claim: create(:claim)) }
  let(:skip_links) { false }

  describe '#rows' do
    it 'has a row for each work item' do
      expect(subject.rows).to eq(
        [
          [
            { header: true, numeric: false, text: 1 },
            { header: true,
              numeric: false,
              text: "<a href=\"/non-standard-magistrates/applications/#{work_item.claim_id}/" \
                    "steps/view_claim/work_item/#{work_item.id}\">Advocacy</a>" },
            { numeric: false, text: nil, html_attributes: { class: 'govuk-!-text-break-anywhere govuk-!-width-one-quarter' } },
            { numeric: true,
              text: '1<span class="govuk-visually-hidden"> hour</span>:40<span class="govuk-visually-hidden"> minutes</span>' },
            { numeric: true, text: '0%' },
            { numeric: true, text: '£109.03' }
          ]
        ]
      )
    end

    context 'when skipping links' do
      let(:skip_links) { true }

      it 'has appropriate text' do
        expect(subject.rows.first[1]).to eq(
          { header: true,
            numeric: false,
            text: 'Advocacy' }
        )
      end
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

      it 'has a row for each work item' do
        expect(subject.rows).to eq(
          [
            [
              { header: true, numeric: false, text: 1 },
              { header: true,
                numeric: false,
                text: '<span id="changed-1" title="This item was adjusted to be a different work item type.">' \
                      "<a href=\"/non-standard-magistrates/applications/#{work_item.claim_id}/steps/view_claim/" \
                      "work_item/#{work_item.id}\">Travel</a></span> <sup><a href=\"#fn1\">[1]</a></sup>" },
              { numeric: false,
                text: 'wrong type',
                html_attributes: { class: 'govuk-!-text-break-anywhere govuk-!-width-one-quarter' } },
              { numeric: true,
                text: '1<span class="govuk-visually-hidden"> hour</span>:40<span class="govuk-visually-hidden"> minutes</span>' },
              { numeric: true, text: '0%' },
              { numeric: true, text: '£46.00' }
            ]
          ]
        )
      end

      context 'when skipping links' do
        let(:skip_links) { true }

        it 'has appropriate text' do
          expect(subject.rows.first[1]).to eq(
            { header: true,
              numeric: false,
              text: '<span id="changed-1" title="This item was adjusted to be a different work item type.">' \
                    'Travel</span> <sup>[1]</sup>' }
          )
        end
      end
    end
  end
end
