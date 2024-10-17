require 'rails_helper'

RSpec.describe Nsm::WorkItemsRow do
  subject { described_class.new(work_item, view) }

  let(:claim) { create(:claim, id: SecureRandom.uuid) }
  let(:work_item) do
    create(:work_item, :medium_risk_values, uplift: '100', position: 1, id: SecureRandom.uuid,
           completed_on: Date.new(2024, 8, 2), claim: claim)
  end
  let(:view) { build_view_context(claim, 'nsm.steps.work_items.edit') }

  context 'when uplift is not allowed' do
    it 'renders a row' do
      expect(subject.cells).to eq(
        [
          { header: true, html_attributes: { id: 'item1' }, numeric: false, text: 1 },
          { header: true, numeric: false,
            text: '<a data-turbo="false" aria-labelledby="itemTitle item1 workType1" id="workType1" ' \
                  "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/work_item/#{work_item.id}\">" \
                  'Preparation</a>' },
          { numeric: false, text: '2 Aug 2024' },
          { numeric: false, text: 'TT' },
          { numeric: true,
  text: '1<span class="govuk-visually-hidden"> hour</span>:40<span class="govuk-visually-hidden"> minutes</span>' },
          { numeric: true,
            text: '<ul class="govuk-summary-list__actions-list"><li class="govuk-summary-list__actions-list-item">' \
                  '<a data-turbo="false" aria-labelledby="duplicate1 itemTitle item1 workType1" id="duplicate1" ' \
                  "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/work_item/" \
                  '00000000-0000-0000-0000-000000000000?work_item_to_duplicate=' \
                  "#{work_item.id}\">Duplicate</a></li><li class=\"govuk-summary-list__actions-list-item\">" \
                  '<a data-turbo="false" aria-labelledby="delete1 itemTitle item1 workType1" id="delete1" ' \
                  "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/work_item_delete/#{work_item.id}\">" \
                  'Delete</a></li></ul>' }
        ]
      )
    end
  end

  context 'when uplift is allowed' do
    let(:claim) { create(:claim, :with_enhanced_rates, id: SecureRandom.uuid) }

    it 'renders a row' do
      expect(subject.cells).to eq(
        [
          { header: true, html_attributes: { id: 'item1' }, numeric: false, text: 1 },
          { header: true, numeric: false,
            text: '<a data-turbo="false" aria-labelledby="itemTitle item1 workType1" id="workType1" ' \
                  "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/work_item/#{work_item.id}\">" \
                  'Preparation</a>' },
          { numeric: false, text: '2 Aug 2024' },
          { numeric: false, text: 'TT' },
          { numeric: true,
            text: '1<span class="govuk-visually-hidden"> hour</span>:' \
                  '40<span class="govuk-visually-hidden"> minutes</span>' },
          { numeric: true, text: '100%' },
          { numeric: true,
            text: '<ul class="govuk-summary-list__actions-list"><li class="govuk-summary-list__actions-list-item">' \
                  '<a data-turbo="false" aria-labelledby="duplicate1 itemTitle item1 workType1" id="duplicate1" ' \
                  "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/work_item/" \
                  '00000000-0000-0000-0000-000000000000?work_item_to_duplicate=' \
                  "#{work_item.id}\">Duplicate</a></li><li class=\"govuk-summary-list__actions-list-item\">" \
                  '<a data-turbo="false" aria-labelledby="delete1 itemTitle item1 workType1" id="delete1" ' \
                  "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/work_item_delete/" \
                  "#{work_item.id}\">Delete</a></li></ul>" }
        ]
      )
    end
  end
end
