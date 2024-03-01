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
      build(:prior_authority_application,
            reason_why: "reason 1\nreason 2",
            supporting_documents: supporting_documents)
    end

    let(:supporting_documents) do
      [
        build(:supporting_document, file_name: 'reason_why1.pdf'),
        build(:supporting_document, file_name: 'reason_why2.pdf'),
      ]
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
            text: 'reason_why1.pdf<br>reason_why2.pdf',
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
