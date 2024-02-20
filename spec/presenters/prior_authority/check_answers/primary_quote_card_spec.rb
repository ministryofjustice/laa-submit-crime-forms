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

  describe '#template' do
    let(:primary_quote) { build(:quote, :primary) }

    it 'stores a template name for rendering' do
      expect(card.template).to eq 'prior_authority/steps/check_answers/primary_quote'
    end
  end

  describe '#row_data' do
    context 'with service type without special rules' do
      let(:application) do
        build(
          :prior_authority_application,
          client_detained: true,
          prior_authority_granted: true,
          service_type: 'telecommunications_expert',
          primary_quote: primary_quote,
        )
      end

      let(:primary_quote) do
        build(
          :quote,
          :primary,
          contact_full_name: 'Jim Bean',
          organisation: 'Post-mortems R us',
          postcode: 'SW1A 1AA',
        )
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'service_name',
            text: 'Telecommunications expert',
          },
          {
            head_key: 'service_details',
            text: 'Jim Bean<br>Post-mortems R us, SW1A 1AA',
          },
          {
            head_key: 'quote_upload',
            text: 'test.png',
          },
          {
            head_key: 'prior_authority_granted',
            text: 'Yes',
          },
        )
      end
    end

    context 'with post mortem relevant service type' do
      let(:application) do
        build(
          :prior_authority_application,
          service_type: 'pathologist_report',
          primary_quote: primary_quote,
        )
      end

      let(:primary_quote) do
        build(
          :quote,
          :primary,
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
      let(:application) do
        build(
          :prior_authority_application,
          service_type: 'telecommunications_expert',
          primary_quote: primary_quote,
        )
      end

      let(:primary_quote) do
        build(:quote, :primary)
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
      let(:application) do
        build(
          :prior_authority_application,
          service_type: 'interpreter',
          primary_quote: primary_quote,
        )
      end

      let(:primary_quote) do
        build(:quote, :primary, ordered_by_court: true)
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
      let(:application) do
        build(
          :prior_authority_application,
          service_type: 'telecommunications_expert',
          primary_quote: primary_quote,
        )
      end

      let(:primary_quote) do
        build(:quote, :primary)
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
          service_type: 'telecommunications_expert',
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

    context 'when travel costs require justification (not prison law, client not detained)' do
      let(:application) do
        build(
          :prior_authority_application,
          prison_law: false,
          client_detained: false,
          service_type: 'telecommunications_expert',
          primary_quote: primary_quote,
        )
      end

      let(:primary_quote) do
        build(:quote, :primary, travel_cost_reason: 'client lives in northern ireland')
      end

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

    context 'when travel costs do NOT require justification (prison law)' do
      let(:application) do
        build(
          :prior_authority_application,
          prison_law: true,
          client_detained: nil,
          service_type: 'telecommunications_expert',
          primary_quote: primary_quote,
        )
      end

      let(:primary_quote) do
        build(:quote, :primary, travel_cost_reason: nil)
      end

      it 'does NOT include travel cost reason row' do
        expect(card.row_data.pluck(:head_key)).not_to include('travel_cost_reason')
      end
    end
  end
end
