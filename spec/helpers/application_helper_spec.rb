require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#maat_required?' do
    let(:form) { double(:form, application:) }
    let(:application) { double(:application, claim_type:) }

    context 'when claim type is not BREACH_OF_INJUNCTION' do
      let(:claim_type) { ClaimType::NON_STANDARD_MAGISTRATE.to_s }

      it { expect(helper).to be_maat_required(form) }
    end

    context 'when claim type is BREACH_OF_INJUNCTION' do
      let(:claim_type) { ClaimType::BREACH_OF_INJUNCTION.to_s }

      it { expect(helper).not_to be_maat_required(form) }
    end
  end

  describe '#relevant_prior_authority_list_anchor' do
    let(:application) { build(:prior_authority_application) }

    it 'returns draft for draft status' do
      allow(application).to receive(:status).and_return('draft')
      expect(helper.relevant_prior_authority_list_anchor(application)).to eq(:draft)
    end

    it 'returns submitted for submitted status' do
      allow(application).to receive(:status).and_return('submitted')
      expect(helper.relevant_prior_authority_list_anchor(application)).to eq(:submitted)
    end

    it 'returns reviewed for all statuses other than draft or submitted' do
      allow(application).to receive(:status).and_return('whatever')
      expect(helper.relevant_prior_authority_list_anchor(application)).to eq(:reviewed)
    end
  end

  describe '#govuk_table_with_cell' do
    let(:head) { [{ text: 'Header 1' }, { text: 'Header 2' }] }
    let(:rows) do
      [
        [{ text: 'Row 1, Cell 1' }, { text: 'Row 1, Cell 2' }],
        [{ text: 'Row 2, Cell 1' }, { text: 'Row 2, Cell 2' }]
      ]
    end

    it 'renders a table with specified head' do
      rendered_table = helper.govuk_table_with_cell(head, rows)
      expect(rendered_table).to have_selector('table')
      expect(rendered_table).to have_selector('thead tr th', text: 'Header 1')
      expect(rendered_table).to have_selector('thead tr th', text: 'Header 2')
    end

    it 'renders a table with specified rows' do
      rendered_table = helper.govuk_table_with_cell(head, rows)
      expect(rendered_table).to have_selector('tbody tr', count: 2)
      expect(rendered_table).to have_selector('tbody tr:first-child td', text: 'Row 1, Cell 1')
      expect(rendered_table).to have_selector('tbody tr:last-child td', text: 'Row 2, Cell 2')
    end

    it 'applies html attributes to a cell' do
      rows_with_attributes = [
        [{ text: 'Row 1, Cell 1', html_attributes: { class: 'starter-pokemon-weights' } }, { text: 'Row 1, Cell 2' }],
        rows[1]
      ]
      rendered_table = helper.govuk_table_with_cell(head, rows_with_attributes)
      expect(rendered_table).to have_selector('tbody tr:first-child td.starter-pokemon-weights', text: 'Row 1, Cell 1')
    end

    it 'treats a cell as a header if header: true' do
      rows_with_header = [
        [{ text: 'Row 1, Cell 1', header: true }, { text: 'Row 1, Cell 2' }],
        rows[1]
      ]
      rendered_table = helper.govuk_table_with_cell(head, rows_with_header)
      expect(rendered_table).to have_selector('tbody tr:first-child th', text: 'Row 1, Cell 1')
    end

    it 'renders a table with a caption' do
      caption = {
        text: 'Summary of work items',
      }
      rendered_table = helper.govuk_table_with_cell(head, rows, caption:)
      expect(rendered_table).to have_selector(
        'caption',
        text: 'Summary of work items'
      )
    end
  end
end
