# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::CaseContactCard do
  subject(:card) { described_class.new(application) }

  describe '#title' do
    let(:application) { build(:prior_authority_application) }

    it 'shows correct title' do
      expect(card.title).to eq('Case contact')
    end
  end

  describe '#row_data' do
    let(:application) do
      build(:prior_authority_application, firm_office:, solicitor:, office_code:)
    end

    let(:solicitor) do
      build(:solicitor, contact_first_name: 'Joe', contact_last_name: 'Bloggs', contact_email: 'joe@bloggs.com')
    end
    let(:firm_office) { build(:firm_office, name: 'Bloggs & Co') }
    let(:office_code) { '2B0N2B' }

    it 'generates expected rows' do
      expect(card.row_data).to eq(
        [
          {
            head_key: 'contact_details',
            text: 'Joe Bloggs<br>joe@bloggs.com'
          },
          {
            head_key: 'firm_details',
            text: 'Bloggs &amp; Co<br>2B0N2B'
          },
        ]
      )
    end
  end
end
