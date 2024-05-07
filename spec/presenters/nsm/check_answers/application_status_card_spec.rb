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
    let(:assessment_comment) { "this is a comment\n2nd line" }

    context 'submitted' do
      let(:claim) { create(:claim, :completed_status, :firm_details, :build_associates, :updated_at, work_items_count: 1) }

      it 'generates submitted rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--primary">Submitted</strong></p>' \
                               '<p>1 December 2023</p><p>Awaiting LAA review</p><br><p>£\d+\.\d\d claimed</p>')
            }
          ]
        )
      end
    end

    context 'granted' do
      let(:claim) { create(:claim, :granted_status, :firm_details, :build_associates, :updated_at, work_items_count: 1) }

      it 'generates granted rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--green">Granted</strong></p>' \
                               '<p>1 December 2023</p><br><p>£(\d+\.\d\d) claimed</p><p>£\1 allowed</p>')
            },
            {
              head_key: 'laa_response', text: '<p>The claim has been fully granted.</p>'
            }
          ]
        )
      end
    end

    context 'part granted' do
      let(:claim) do
        create(:claim, :part_granted_status, :firm_details, :build_associates, :updated_at, work_items_count: 1, assessment_comment: assessment_comment)
      end

      it 'generates part granted rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--blue">Part Granted</strong></p>' \
                               '<p>1 December 2023</p><br><p>£\d+\.\d\d claimed</p><p>Pending Data</p>')
            },
            {
              head_key: 'laa_response',
              text: '<p>this is a comment</p><p>2nd line</p>' \
                    '<p><ul class="govuk-list govuk-list--bullet">' \
                    '<li><a class="govuk-link govuk-link--no-visited-state" href="/non-standard-magistrates/applications/' \
                    "#{claim.id}/steps/view_claim?section=adjustments#work_items\">" \
                    'Review adjustments to work items</a></li><li><a class="govuk-link govuk-link--no-visited-state" ' \
                    "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/view_claim?" \
                    'section=adjustments#letters_and_calls">Review adjustments to letters and calls</a></li>' \
                    '<li><a class="govuk-link govuk-link--no-visited-state" href="/non-standard-magistrates/applications/' \
                    "#{claim.id}/steps/view_claim?section=adjustments#disbursements\">Review adjustments " \
                    'to disbursements</a></li></ul></p><p><a class="govuk-button govuk-!-margin-bottom-0" data-module="govuk-button" ' \
                    "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/view_claim\">" \
                    'How to appeal this decision</a></p>'
            }
          ]
        )
      end

      context 'no work items' do
        let(:claim) { create(:claim, :part_granted_status, :firm_details, :updated_at, assessment_comment:) }

        it 'generates part granted rows' do
          expect(subject.row_data).to match(
            [
              {
                head_key: 'application_status',
                text: Regexp.new('<p><strong class="govuk-tag govuk-tag--blue">Part Granted</strong></p>' \
                                 '<p>1 December 2023</p><br><p>£\d+\.\d\d claimed</p><p>Pending Data</p>')
              },
              {
                head_key: 'laa_response',
                text: '<p>this is a comment</p><p>2nd line</p>' \
                      '<p><ul class="govuk-list govuk-list--bullet">' \
                      '<li><a class="govuk-link govuk-link--no-visited-state" ' \
                      "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/view_claim?" \
                      'section=adjustments#letters_and_calls">Review adjustments to letters and calls</a></li>' \
                      '<li><a class="govuk-link govuk-link--no-visited-state" href="/non-standard-magistrates/' \
                      "applications/#{claim.id}/steps/view_claim?section=adjustments#disbursements\">Review " \
                      'adjustments to disbursements</a></li></ul></p><p>' \
                      '<a class="govuk-button govuk-!-margin-bottom-0" data-module="govuk-button" ' \
                      "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/view_claim\">How to appeal " \
                      'this decision</a></p>'
              }
            ]
          )
        end
      end
    end

    context 'review' do
      let(:claim) { create(:claim, :review_status, :firm_details, :build_associates, :updated_at, work_items_count: 1, assessment_comment: assessment_comment) }

      it 'generates review rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--yellow\">Update needed</strong></p><p>1 December 2023</p>' \
                               '<br><p>£\d+\.\d\d claimed</p>')

            },
            {
              head_key: 'laa_response',
              text: '<p>this is a comment</p><p>2nd line</p><p><span class="govuk-!-font-weight-bold">Update your claim</span>' \
                    '</p><p>To update your claim, email <a href="mailto:magsbilling@justice.gov.uk">magsbilling@justice.gov.uk</a> ' \
                    "with the LAA case reference in the subject of the email and include any supporting information requested.\n</p>"
            }
          ]
        )
      end
    end

    context 'further info' do
      let(:claim) do
        create(:claim, :further_info_status, :firm_details, :build_associates, :updated_at, work_items_count: 1, assessment_comment: assessment_comment)
      end

      it 'generates further info rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--yellow\">Update needed</strong></p><p>1 December 2023</p>' \
                               '<br><p>£\d+\.\d\d claimed</p>')

            },
            {
              head_key: 'laa_response',
              text: '<p>this is a comment</p><p>2nd line</p><p><span class="govuk-!-font-weight-bold">Update your claim</span>' \
                    '</p><p>To update your claim, email <a href="mailto:magsbilling@justice.gov.uk">magsbilling@justice.gov.uk</a> ' \
                    "with the LAA case reference in the subject of the email and include any supporting information requested.\n</p>"
            }
          ]
        )
      end
    end

    context 'provider requested' do
      let(:claim) do
        create(:claim, :provider_requested_status, :firm_details, :build_associates, :updated_at, work_items_count: 1, assessment_comment: assessment_comment)
      end

      it 'generates provider requested rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--yellow">Provider request</strong></p>' \
                               '<p>1 December 2023</p><br><p>£\d+\.\d\d claimed</p>')
            },
            {
              head_key: 'laa_response',
              text: '<p>this is a comment</p><p>2nd line</p><p><span class="govuk-!-font-weight-bold">Update your ' \
                    'claim</span></p><p>To update your claim, email <a href="mailto:magsbilling@justice.gov.uk">' \
                    'magsbilling@justice.gov.uk</a> with the LAA case reference in the subject of the email and include ' \
                    "your new information.\n</p>"
            }
          ]
        )
      end
    end

    context 'rejected' do
      let(:claim) do
        create(:claim, :rejected_status, :firm_details, :build_associates, :updated_at, work_items_count: 1, assessment_comment: assessment_comment)
      end

      it 'generates rejected rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--red">Rejected</strong></p><p>1 December 2023</p>' \
                               '<br><p>£\d+\.\d\d claimed</p><p>£0.00 allowed</p>')

            },
            {
              head_key: 'laa_response',
              text: '<p>this is a comment</p><p>2nd line</p>' \
                    '<p><a class="govuk-button govuk-!-margin-bottom-0" data-module="govuk-button" ' \
                    "href=\"/non-standard-magistrates/applications/#{claim.id}/steps/view_claim\">" \
                    'How to appeal this decision</a></p>'
            }
          ]
        )
      end
    end
  end
end
