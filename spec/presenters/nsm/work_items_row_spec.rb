require 'rails_helper'

RSpec.describe Nsm::WorkItemsRow do
  subject { described_class.new(work_item, view) }

  let(:claim) { build(:claim, id: SecureRandom.uuid) }
  let(:work_item) { build(:work_item, :medium_risk_values, id: SecureRandom.uuid) }
  let(:controller_instance) { ApplicationController.new }
  let(:view) do
    controller_instance.set_request!(request)
    controller_instance.view_context.tap { _1.instance_variable_set(:@virtual_path, 'nsm.steps.work_items.edit') }
  end
  let(:request) do
    double(
      :request,
      host: 'test.com', protocol: 'http', path_parameters: {},
      engine_script_name: nil, original_script_name: nil
    ).as_null_object
  end

  before do
    allow(view).to receive(:current_application).and_return(claim)
  end

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
            text: '<uk class="govuk-summary-list__actions-list"><li class="govuk-summary-list__actions-list-item">' \
                  '<a data-turbo="false" aria-labelledby="duplicate1 itemTitle item1 workType1" id="duplicate1" ' \
                  "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/work_item/#{work_item.id}/" \
                  'duplicate\">Duplicate</a></li><li class="govuk-summary-list__actions-list-item">' \
                  '<a data-turbo="false" aria-labelledby="delete1 itemTitle item1 workType1" id="workType1" ' \
                  "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/work_item_delete/#{work_item.id}\">" \
                  'Delete</a></li></uk>' }
        ]
      )
    end
  end

  context 'when uplift is allowed' do
    let(:claim) { build(:claim, :with_enhanced_rates, id: SecureRandom.uuid) }
    let(:work_item) { build(:work_item, :medium_risk_values, uplift: '100', id: SecureRandom.uuid) }

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
            text: '<uk class="govuk-summary-list__actions-list"><li class="govuk-summary-list__actions-list-item">' \
                  '<a data-turbo="false" aria-labelledby="duplicate1 itemTitle item1 workType1" id="duplicate1" ' \
                  "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/work_item/#{work_item.id}/" \
                  'duplicate\">Duplicate</a></li><li class="govuk-summary-list__actions-list-item">' \
                  '<a data-turbo="false" aria-labelledby="delete1 itemTitle item1 workType1" id="workType1" ' \
                  "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/work_item_delete/" \
                  "#{work_item.id}\">Delete</a></li></uk>" }
        ]
      )
    end
  end
end
