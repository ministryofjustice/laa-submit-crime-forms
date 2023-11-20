# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckAnswers::ApplicationStatusCard do
  subject { described_class.new(claim) }

  describe '#title' do
    let(:claim) { build(:claim) }

    it 'shows correct title' do
      expect(subject.title).to eq('Status')
    end
  end

  describe '#row data' do
    context 'submitted' do
      let(:claim) { build(:claim, :completed_status, :updated_at) }

      it 'generates submitted rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'application_status',
              text: '<strong class="govuk-tag govuk-tag--primary">Submitted</strong>'
            },
            {
              head_key: 'Date Submitted',
              text: '01 December 2023'
            }
          ]
        )
      end
    end

    context 'granted' do
      let(:claim) { build(:claim, :granted_status) }

      it 'generates granted rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'application_status',
              text: '<strong class="govuk-tag govuk-tag--green">Granted</strong>'
            },
            {
              head_key: 'Date Assessed',
              text: nil
            }
          ]
        )
      end
    end

    context 'part granted' do
      let(:claim) { build(:claim, :part_granted_status) }

      it 'generates part granted rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'application_status',
              text: '<strong class="govuk-tag govuk-tag--blue">Part Granted</strong>'
            },
            {
              head_key: 'Date Assessed',
              text: nil
            }
          ]
        )
      end
    end

    context 'review' do
      let(:claim) { build(:claim, :review_status) }

      it 'generates review rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'application_status',
              text: '<strong class="govuk-tag govuk-tag--yellow">Further Information Requested</strong>'
            },
            {
              head_key: 'Date Returned',
              text: nil
            }
          ]
        )
      end
    end

    context 'rejected' do
      let(:claim) { build(:claim, :rejected_status) }

      it 'generates rejected rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'application_status',
              text: '<strong class="govuk-tag govuk-tag--red">Rejected</strong>'
            },
            {
              head_key: 'Date Returned',
              text: nil
            }
          ]
        )
      end
    end
  end
end
