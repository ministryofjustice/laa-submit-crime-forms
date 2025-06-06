# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::HearingDetailCard do
  subject(:card) { described_class.new(application) }

  let(:incomplete_tag) { '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>' }

  describe '#title' do
    let(:application) { build(:prior_authority_application) }

    it 'shows correct title' do
      expect(card.title).to eq('Hearing details')
    end
  end

  describe '#row_data' do
    context 'when next hearing date known' do
      let(:application) do
        build(:prior_authority_application,
              next_hearing: true,
              next_hearing_date: 1.month.from_now.to_date)
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'next_hearing_date',
            text: 1.month.from_now.to_date.to_fs(:stamp),
          },
        )
      end
    end

    context 'when next hearing date NOT known' do
      let(:application) do
        build(:prior_authority_application,
              next_hearing: false,
              next_hearing_date: nil)
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'next_hearing_date',
            text: 'Not known',
          },
        )
      end
    end

    context 'when next hearing date known but not entered' do
      let(:application) do
        build(:prior_authority_application,
              next_hearing: true,
              next_hearing_date: nil)
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'next_hearing_date',
            text: incomplete_tag,
          },
        )
      end
    end

    context 'when court type not entered' do
      let(:application) do
        build(:prior_authority_application,
              court_type: nil)
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'court_type',
            text: incomplete_tag,
          },
        )
      end
    end

    context 'when magistrates\' court' do
      let(:application) do
        build(:prior_authority_application,
              plea: 'mixed',
              court_type: 'magistrates_court',
              youth_court: true)
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'plea',
            text: 'Mixed plea',
          },
          {
            head_key: 'court_type',
            text: 'Magistrates\' court',
          },
          {
            head_key: 'youth_court',
            text: 'Yes',
          },
        )
      end
    end

    context 'when magistrates\' court with missing data' do
      let(:application) do
        build(:prior_authority_application,
              plea: nil,
              court_type: 'magistrates_court',
              youth_court: nil)
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'plea',
            text: incomplete_tag,
          },
          {
            head_key: 'court_type',
            text: 'Magistrates\' court',
          },
          {
            head_key: 'youth_court',
            text: incomplete_tag,
          },
        )
      end
    end

    context 'when central criminal court with psychiatric liason not accessed' do
      let(:application) do
        build(:prior_authority_application,
              plea: 'not_guilty',
              court_type: 'central_criminal_court',
              psychiatric_liaison: false,
              psychiatric_liaison_reason_not: 'whatever')
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'plea',
            text: 'Not guilty',
          },
          {
            head_key: 'court_type',
            text: 'Central Criminal Court',
          },
          {
            head_key: 'psychiatric_liaison',
            text: 'No',
          },
          {
            head_key: 'psychiatric_liaison_reason_not',
            text: '<p>whatever</p>',
          },
        )
      end
    end

    context 'when central criminal court with psychiatric liason accessed' do
      let(:application) do
        build(:prior_authority_application,
              plea: 'not_guilty',
              court_type: 'central_criminal_court',
              psychiatric_liaison: true)
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'plea',
            text: 'Not guilty',
          },
          {
            head_key: 'court_type',
            text: 'Central Criminal Court',
          },
          {
            head_key: 'psychiatric_liaison',
            text: 'Yes',
          },
        )
      end
    end

    context 'when crown court' do
      let(:application) do
        build(:prior_authority_application,
              plea: 'unknown',
              court_type: 'crown_court',
              youth_court: true)
      end

      it 'generates expected rows' do
        expect(card.row_data).to include(
          {
            head_key: 'plea',
            text: 'Unknown',
          },
          {
            head_key: 'court_type',
            text: 'Crown Court (excluding Central Criminal Court)',
          },
        )
      end
    end
  end
end
