# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::PrimaryQuoteCard do
  subject(:card) { described_class.new(application) }

  let(:application) do
    build(
      :prior_authority_application,
      primary_quote:,
    )
  end

  describe '#title' do
    let(:primary_quote) { build(:quote, :primary) }

    it 'shows correct title' do
      expect(card.title).to eq('Primary quote')
    end
  end

  describe '#row_data' do
    context 'with service type without special rules' do
      let(:application) do
        build(
          :prior_authority_application,
          client_detained: true,
          prior_authority_granted: true,
          primary_quote: primary_quote,
        )
      end

      let(:primary_quote) do
        build(
          :quote,
          :primary,
          service_type: 'telecoms_expert',
          contact_full_name: 'Jim Bean',
          organisation: 'Post-mortems R us',
          postcode: 'SW1A 1AA',
        )
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'service_name',
            text: 'Telecoms Expert',
          },
          {
            head_key: 'service_details',
            text: 'Jim Bean<br>Post-mortems R us, SW1A 1AA',
          },
          {
            head_key: 'quote_upload',
            text: 'TODO',
          },
          {
            head_key: 'prior_authority_granted',
            text: 'Yes',
          },
          {
            head_key: 'summary',
            text: kind_of(String),
          },
        )
      end
    end

    context 'with post mortem relevant service type' do
      let(:primary_quote) do
        build(
          :quote,
          :primary,
          service_type: 'pathologist',
          related_to_post_mortem: true,
        )
      end

      it 'adds the related to post mortem row' do
        expect(card.row_data)
          .to include(
            {
              head_key: 'related_to_post_mortem',
              text: 'Yes',
            },
          )
      end
    end

    context 'without post mortem relevant service type' do
      let(:primary_quote) do
        build(
          :quote,
          :primary,
          service_type: 'telecoms_expert',
        )
      end

      it 'does not add the related to post mortem row' do
        expect(card.row_data)
          .not_to include(
            {
              head_key: 'related_to_post_mortem',
              text: kind_of(String),
            },
          )
      end
    end

    context 'with court order[ed] relevant service type' do
      let(:primary_quote) do
        build(
          :quote,
          :primary,
          service_type: 'interpreters',
          ordered_by_court: true,
        )
      end

      it 'adds the ordered by court row' do
        expect(card.row_data)
          .to include(
            {
              head_key: 'ordered_by_court',
              text: 'Yes',
            },
          )
      end
    end

    context 'without court order[ed] relevant service type' do
      let(:primary_quote) do
        build(
          :quote,
          :primary,
          service_type: 'telecoms_expert',
        )
      end

      it 'does not add the ordered by court row' do
        expect(card.row_data)
          .not_to include(
            {
              head_key: 'ordered_by_court',
              text: kind_of(String),
            },
          )
      end
    end

    context 'when client detained' do
      let(:application) do
        build(
          :prior_authority_application,
          client_detained: true,
          primary_quote: primary_quote,
        )
      end

      let(:primary_quote) { build(:quote, :primary) }

      it 'does not add the travel cost reason row' do
        expect(card.row_data)
          .not_to include(
            {
              head_key: 'travel_cost_reason',
              text: kind_of(String),
            },
          )
      end
    end

    context 'when client NOT detained' do
      let(:application) do
        build(
          :prior_authority_application,
          client_detained: false,
          travel_cost_reason: 'client lives in northern ireland',
          primary_quote: primary_quote,
        )
      end

      let(:primary_quote) { build(:quote, :primary) }

      it 'adds the travel cost reason row' do
        expect(card.row_data)
          .to include(
            {
              head_key: 'travel_cost_reason',
              text: 'client lives in northern ireland',
            },
          )
      end
    end
  end
end
