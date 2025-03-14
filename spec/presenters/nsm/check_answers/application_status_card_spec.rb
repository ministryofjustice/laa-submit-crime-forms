# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::ApplicationStatusCard do
  subject(:card) { described_class.new(claim) }

  describe '#title' do
    let(:claim) { build(:claim) }

    it 'shows correct title' do
      expect(subject.title).to eq('Claim status')
    end
  end

  describe '#row data' do
    let(:assessment_comment) { "this is a comment\n2nd line" }

    context 'when in submitted state' do
      let(:claim) do
        create(:claim, :completed_state, :case_type_breach, :firm_details, :build_associates, :updated_at, work_items_count: 1)
      end

      it 'generates submitted rows' do
        expect(card.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--light-blue">Submitted</strong></p>' \
                               '<p>1 December 2023</p><p>Awaiting LAA review</p><br><p>£\d+\.\d\d claimed</p>')
            }
          ]
        )
      end
    end

    context 'when in granted state' do
      let(:claim) do
        create(:claim, :granted_state, :case_type_breach, :firm_details, :build_associates, :updated_at, work_items_count: 1)
      end

      it 'generates granted rows with fallback comment' do
        expect(card.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--green">Granted</strong></p>' \
                               '<p>1 December 2023</p><br><p>£[\d,\.]+ claimed</p><p>£[\d,\.]+ allowed</p>')
            },
            {
              head_key: 'laa_response',
              text: '<p>The claim has been fully granted.</p>'
            }
          ]
        )
      end

      context 'with a comment' do
        before { claim.update(assessment_comment: "Foo\n<b>Bar</b>") }

        it 'shows the comment, escaped appropriately' do
          expect(card.row_data[1][:text]).to eq('<p>Foo</p><p>&lt;b&gt;Bar&lt;/b&gt;</p>')
        end
      end
    end

    context 'when in part granted state' do
      let(:claim) do
        create(
          :claim, :case_type_breach,
          :part_granted_state, :firm_details, :build_associates, :updated_at, :adjusted_letters_calls,
          work_items_count: 1, work_items_adjusted: true,
          disbursements_count: 1, disbursements_adjusted: true,
          assessment_comment: assessment_comment
        )
      end

      it 'generates part granted rows' do
        expect(card.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--blue">Part granted</strong></p>' \
                               '<p>1 December 2023</p><br><p>£\d+\.\d\d claimed</p><p>£\d+\.\d\d allowed</p>')
            },
            {
              head_key: 'laa_response',
              text: Regexp.new('<p>this is a comment</p><p>2nd line</p>')
            }
          ]
        )
      end

      context 'when firm is NOT VAT registered' do
        before do
          claim.firm_office.update(vat_registered: 'no')
        end

        let(:claim) { create(:claim, :part_granted_state, :case_type_breach, :firm_details, :updated_at, assessment_comment:) }

        it 'generates no links in text' do
          expect(card.row_data).to match(
            [
              {
                head_key: 'application_status',
                text: Regexp.new('<p><strong class="govuk-tag govuk-tag--blue">Part granted</strong></p>' \
                                 '<p>1 December 2023</p><br><p>£\d+\.\d\d claimed</p><p>£\d+\.\d\d allowed</p>')
              },
              {
                head_key: 'laa_response',
                text: '<p>this is a comment</p><p>2nd line</p><p><ul class="govuk-list govuk-list--bullet"></ul></p>' \
                      "<h3 class=\"govuk-heading-s\">Appeal the adjustment</h3>\n<p>If you want to appeal the adjustment, " \
                      'email or post a detailed explanation of the grounds of your appeal and any supporting documents to:' \
                      "</p>\n<ul class=\"govuk-list govuk-list--bullet\">\n  <li><a href=\"mailto:CRM7appeal" \
                      '@justice.gov.uk">CRM7appeal@justice.gov.uk</a>, with the LAA case reference in the subject of the ' \
                      "email</li>\n  <li>Nottingham Office, 3rd Floor B3.20, 1 Unity Square, Queensbridge Road, " \
                      "Nottingham NG2 1AW, or DX 10035 Nottingham 1</li>\n</ul>\n<p>Appeals may be considered by LAA " \
                      'caseworkers or sent to an independent costs assessor (ICA). You can only appeal once. The ICA’s ' \
                      "decision is final (as stated in the Criminal Bills Assessment Manual (CBAM) rule 4.4.1).</p>\n"
              }
            ]
          )
        end
      end

      context 'with no adjustements' do
        let(:claim) { create(:claim, :part_granted_state, :case_type_breach, :firm_details, :updated_at, assessment_comment:) }

        it 'generates no links in text' do
          expect(card.row_data).to match(
            [
              {
                head_key: 'application_status',
                text: '<p><strong class="govuk-tag govuk-tag--blue">Part granted</strong></p>' \
                      '<p>1 December 2023</p><br><p>£0.00 claimed</p><p>£0.00 allowed</p>'
              },
              {
                head_key: 'laa_response',
                text: '<p>this is a comment</p><p>2nd line</p><p><ul class="govuk-list govuk-list--bullet"></ul></p>' \
                      "<h3 class=\"govuk-heading-s\">Appeal the adjustment</h3>\n<p>If you want to appeal the adjustment, " \
                      'email or post a detailed explanation of the grounds of your appeal and any supporting documents to:' \
                      "</p>\n<ul class=\"govuk-list govuk-list--bullet\">\n  <li><a href=\"mailto:CRM7appeal" \
                      '@justice.gov.uk">CRM7appeal@justice.gov.uk</a>, with the LAA case reference in the subject of the ' \
                      "email</li>\n  <li>Nottingham Office, 3rd Floor B3.20, 1 Unity Square, Queensbridge Road, " \
                      "Nottingham NG2 1AW, or DX 10035 Nottingham 1</li>\n</ul>\n<p>Appeals may be considered by LAA " \
                      'caseworkers or sent to an independent costs assessor (ICA). You can only appeal once. The ICA’s ' \
                      "decision is final (as stated in the Criminal Bills Assessment Manual (CBAM) rule 4.4.1).</p>\n"
              }
            ]
          )
        end
      end

      context 'with adjustments' do
        let(:claim) do
          create(
            :claim, :case_type_breach,
            :part_granted_state,
            :firm_details,
            :updated_at,
            :adjusted_letters_calls,
            :build_associates,
            assessment_comment: assessment_comment,
            work_items_count: 1,
            work_items_adjusted: true,
            disbursements_count: 1,
            disbursements_adjusted: true,
          )
        end

        it 'generates links to adjusted items tabs' do
          all_text = card.row_data.pluck(:text).join

          # rubocop:disable Layout/LineLength
          expect(all_text)
            .to match(%r{<a class="govuk-link.*" href=".*/steps/view_claim/adjusted/work_items#cost-summary-table">Review adjustments to work items</a>})
            .and match(%r{<a class="govuk-link.*" href=".*/steps/view_claim/adjusted/letters_and_calls#cost-summary-table">Review adjustments to letters and calls</a>})
            .and match(%r{<a class="govuk-link.*" href=".*/steps/view_claim/adjusted/disbursements#cost-summary-table">Review adjustments to disbursements</a>})
          # rubocop:enable Layout/LineLength
        end
      end
    end

    context 'when in provider update requested state' do
      let(:claim) do
        create(:claim, :sent_back_state, :case_type_breach, :firm_details, :build_associates, :updated_at, work_items_count: 1,
assessment_comment: assessment_comment)
      end

      it 'generates sent back rows' do
        expect(card.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--yellow">Update needed</strong></p>' \
                               '<p>1 December 2023</p><br><p>£\d+\.\d\d claimed</p>')
            },
            {
              head_key: 'laa_response',
              text: '<p>this is a comment</p><p>2nd line</p><p><span class="govuk-!-font-weight-bold">Update your ' \
                    'claim</span></p><p>To update your claim, email <a href="mailto:CRM7fi.request@justice.gov.uk">' \
                    'CRM7fi.request@justice.gov.uk</a> with the LAA case reference in the subject of the email and include ' \
                    "any supporting information requested.\n</p>"
            }
          ]
        )
      end
    end

    context 'when in sent back requested state and nsm rfi loop enabled' do
      let(:claim) do
        create(:claim, :sent_back_state, :case_type_breach, :firm_details, :build_associates, :updated_at,
               :with_further_information_request, work_items_count: 1, assessment_comment: assessment_comment)
      end

      it 'generates sent back rows' do
        # rubocop:disable Layout/LineLength
        expect(card.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--yellow">Update needed</strong></p>' \
                               '<p>1 December 2023</p><br><p>£\d+\.\d\d claimed</p>')
            },
            {
              head_key: 'laa_response',
              text: '<p>Updates are needed to proceed with your claim.</p>' \
                    '<p>Review the requests and resubmit your claim by <strong>2 January 2024</strong></p>' \
                    '<p>After this date your claim will be automatically closed</p>' \
                    '<h3 class="govuk-heading-s">Further information request</h3>' \
                    '<p>please provide further evidence</p>' \
                    "<p><a class=\"govuk-button\" data-module=\"govuk-button\" href=\"/non-standard-magistrates/applications/#{claim.id}/steps/further_information\">Update claim</a></p>"
            }
          ]
        )
        # rubocop:enable Layout/LineLength
      end
    end

    context 'when in rejected state' do
      let(:claim) do
        create(:claim, :rejected_state, :case_type_breach, :firm_details, :build_associates, :updated_at, work_items_count: 1,
assessment_comment: assessment_comment)
      end

      it 'generates rejected rows' do
        expect(card.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--red">Rejected</strong></p><p>1 December 2023</p>' \
                               '<br><p>£\d+\.\d\d claimed</p><p>£0.00 allowed</p>')

            },
            {
              head_key: 'laa_response',
              text: Regexp.new('<p>this is a comment</p><p>2nd line</p>')
            }
          ]
        )
      end
    end
  end
end
