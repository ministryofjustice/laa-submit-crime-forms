# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::ApplicationStatusCard do
  subject { described_class.new(claim) }

  describe '#title' do
    let(:claim) { build(:claim) }

    it 'shows correct title' do
      expect(subject.title).to eq('Claim status')
    end
  end

  describe '#row data' do
    context 'submitted' do
      let(:claim) { build(:claim, :completed_status, :firm_details, :updated_at) }

      it 'generates submitted rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'application_status',
              text: '<p><strong class="govuk-tag govuk-tag--primary">Submitted</strong></p>' \
                    '<p>1 December 2023</p><p>Awaiting LAA review</p><br><p>£0.00 claimed</p>'
            }
          ]
        )
      end
    end

    context 'granted' do
      let(:claim) { create(:claim, :granted_status, :firm_details, :build_associates, :updated_at, work_items_count: 1) }

      it 'generates granted rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'application_status',
              text: '<p><strong class="govuk-tag govuk-tag--green">Granted</strong></p>' \
                    '<p>1 December 2023</p><br><p>£0.00 claimed</p><p>£0.00 allowed</p>'
            },
            {
              head_key: 'laa_response', text: '<p>Fake LAA Response</p>'
            }
          ]
        )
      end
    end

    context 'part granted' do
      let(:claim) { create(:claim, :part_granted_status, :firm_details, :build_associates, :updated_at, work_items_count: 1) }

      it 'generates part granted rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: '<p><strong class="govuk-tag govuk-tag--blue">Part Granted</strong></p>' \
                    '<p>1 December 2023</p><br><p>£28.15 claimed</p><p>Pending Data</p>'
            },
            {
              head_key: 'laa_response',
              text: '<p>Fake LAA Response</p><p></p>' \
                    '<ul class="govuk-list govuk-list--bullet">' \
                    '<li><a class="govuk-link govuk-link--no-visited-state" href="/non-standard-magistrates/applications/' \
                    '[a-e0-9\-]+/steps/view_claim?section=adjustments#work_items">' \
                    'Review adjustments to work items</a></li><li><a class="govuk-link govuk-link--no-visited-state" ' \
                    'href="/non-standard-magistrates/applications/[a-e0-9\-]+/steps/view_claim?' \
                    'section=adjustments#letters_and_calls">Review adjustments to letters and calls</a></li>' \
                    '<li><a class="govuk-link govuk-link--no-visited-state" href="/non-standard-magistrates/applications/' \
                    '[a-e0-9\-]+/steps/view_claim?section=adjustments#disbursements">Review adjustments ' \
                    'to disbursements</a></li></ul><p></p><p><a class="govuk-button govuk-!-margin-bottom-0" ' \
                    'href="/non-standard-magistrates/applications/[a-e0-9\-]+/steps/view_claim">' \
                    'How to appeal this decision</a></p>'
            }
          ]
        )
      end
    end

    context 'review' do
      let(:claim) { build(:claim, :review_status, :firm_details, :updated_at) }

      it 'generates review rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'application_status',
              text: '<p><strong class="govuk-tag govuk-tag--yellow">Further Information Requested</strong></p>' \
                    '<p>1 December 2023</p><br><p>£0.00 claimed</p><p>Pending Data</p>'
            },
            { head_key: 'laa_response', text: '<p>Fake LAA Response</p>' }
          ]
        )
      end
    end

    context 'further info' do
      let(:claim) { build(:claim, :further_info_status, :firm_details, :updated_at) }

      it 'generates further info rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'application_status',
              text: '<p><strong class="govuk-tag govuk-tag--yellow">Further Information Requested</strong></p>' \
                    '<p>1 December 2023</p><br><p>£0.00 claimed</p><p>Pending Data</p>'
            },
            { head_key: 'laa_response', text: '<p>Fake LAA Response</p>' }
          ]
        )
      end
    end

    context 'provider requested' do
      let(:claim) { build(:claim, :provider_requested_status, :firm_details, :updated_at) }

      it 'generates provider requested rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'application_status',
              text: '<p><strong class="govuk-tag govuk-tag--yellow">Further Information Requested</strong></p>' \
                    '<p>1 December 2023</p><br><p>£0.00 claimed</p><p>Pending Data</p>'
            },
            { head_key: 'laa_response', text: '<p>Fake LAA Response</p>' }
          ]
        )
      end
    end

    context 'rejected' do
      let(:claim) do
        create(:claim, :rejected_status, :firm_details, :build_associates, id: SecureRandom.uuid, work_items_count: 1)
      end

      it 'generates rejected rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: '<p><strong class="govuk-tag govuk-tag--red">Rejected</strong></p><p>30 April 2024</p>' \
                    '<br><p>£\d+.\d\d claimed</p><p>£0.00 allowed</p>'

            },
            {
              head_key: 'laa_response',
              text: '<p>Fake LAA Response</p>' \
                    '<p><a class="govuk-button govuk-!-margin-bottom-0" href="/non-standard-magistrates/' \
                    'applications/[a-e0-9\-]+/steps/view_claim">How to appeal this decision</a></p>'
            }
          ]
        )
      end
    end
  end
end
