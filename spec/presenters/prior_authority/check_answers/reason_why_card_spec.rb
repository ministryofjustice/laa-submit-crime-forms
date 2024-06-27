# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::ReasonWhyCard do
  subject(:card) { described_class.new(application) }

  describe '#title' do
    let(:application) { build(:prior_authority_application) }

    it 'shows correct title' do
      expect(card.title).to eq('Reason for prior authority')
    end
  end

  describe '#row_data' do
    let(:application) do
      create(:prior_authority_application,
             reason_why: "reason 1\nreason 2",
             supporting_documents: supporting_documents)
    end

    let(:first_doc) { build(:supporting_document, file_name: 'reason_why1.pdf') }
    let(:second_doc) { build(:supporting_document, file_name: 'reason_why2.pdf') }
    let(:supporting_documents) do
      [first_doc, second_doc]
    end

    it 'generates expected rows' do
      expect(card.row_data).to eq(
        [
          {
            head_key: 'reason_why',
            text: "<p>reason 1\n<br />reason 2</p>",
          },
          {
            head_key: 'supporting_documents',
            text: "<a class=\"govuk-link\" href=\"/prior-authority/downloads/#{first_doc.id}\">reason_why1.pdf</a><br>" \
                  "<a class=\"govuk-link\" href=\"/prior-authority/downloads/#{second_doc.id}\">reason_why2.pdf</a>",
          },
        ]
      )
    end

    context 'when there are no documents' do
      let(:supporting_documents) { [] }

      it 'generates expected rows' do
        expect(card.row_data).to eq(
          [
            {
              head_key: 'reason_why',
              text: "<p>reason 1\n<br />reason 2</p>",
            },
            {
              head_key: 'supporting_documents',
              text: 'None',
            },
          ]
        )
      end
    end
  end
end
