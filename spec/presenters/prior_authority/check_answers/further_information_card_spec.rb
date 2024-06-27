# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::FurtherInformationCard do
  subject(:card) { described_class.new(application) }

  let(:application) do
    create(
      :prior_authority_application,
      further_informations: [
        build(
          :further_information,
          :with_response,
          supporting_documents:
        )
      ]
    )
  end

  describe '#title' do
    let(:supporting_documents) { [] }

    it 'shows correct title' do
      expect(card.title).to eq('Further information requested')
    end
  end

  describe '#row_data' do
    context 'with supporting documents' do
      let(:first_doc) { build(:supporting_document, file_name: 'further_info1.pdf') }
      let(:second_doc) { build(:supporting_document, file_name: 'further_info2.pdf') }
      let(:supporting_documents) do
        [first_doc, second_doc]
      end

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'information_requested',
              text: '<p>please provide further evidence</p>',
            },
            {
              head_key: 'information_supplied',
              text: '<p>here is the extra information you requested</p>',
            },
            {
              head_key: 'supporting_documents',
              text: "<a class=\"govuk-link\" href=\"/prior-authority/downloads/#{first_doc.id}\">further_info1.pdf</a><br>" \
                    "<a class=\"govuk-link\" href=\"/prior-authority/downloads/#{second_doc.id}\">further_info2.pdf</a>",
            },
          ]
        )
      end
    end

    context 'with no supporting documents' do
      let(:supporting_documents) { [] }

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'supporting_documents',
            text: 'None',
          },
        )
      end
    end
  end
end
