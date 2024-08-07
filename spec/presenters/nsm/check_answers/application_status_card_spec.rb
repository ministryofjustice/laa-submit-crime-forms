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

    context 'submitted' do
      let(:claim) { create(:claim, :completed_status, :firm_details, :build_associates, :updated_at, work_items_count: 1) }

      it 'generates submitted rows' do
        expect(subject.row_data).to match(
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

      context 'with a comment' do
        before { claim.update(assessment_comment: "Foo\n<b>Bar</b>") }

        it 'shows the comment, escaped appropriately' do
          expect(subject.row_data[1][:text]).to eq('<p>Foo</p><p>&lt;b&gt;Bar&lt;/b&gt;</p>')
        end
      end
    end

    context 'part granted' do
      let(:claim) do
        create(
          :claim,
          :part_granted_status, :firm_details, :build_associates, :updated_at, :adjusted_letters_calls,
          work_items_count: 1, work_items_adjusted: true,
          disbursements_count: 1, disbursements_adjusted: true,
          assessment_comment: assessment_comment
        )
      end

      it 'generates part granted rows' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'application_status',
              text: Regexp.new('<p><strong class="govuk-tag govuk-tag--blue">Part Granted</strong></p>' \
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

        let(:claim) { create(:claim, :part_granted_status, :firm_details, :updated_at, assessment_comment:) }

        it 'generates no links in text' do
          expect(subject.row_data).to match(
            [
              {
                head_key: 'application_status',
                text: Regexp.new('<p><strong class="govuk-tag govuk-tag--blue">Part Granted</strong></p>' \
                                 '<p>1 December 2023</p><br><p>£\d+\.\d\d claimed</p><p>£\d+\.\d\d allowed</p>')
              },
              {
                head_key: 'laa_response',
                text: '<p>this is a comment</p><p>2nd line</p><p><ul class="govuk-list govuk-list--bullet"></ul></p><p>' \
                      "<h3 class=\"govuk-heading-s\">Appeal the adjustment</h3>\n<p>If you want to appeal the adjustment, " \
                      'email or post a detailed explanation of the grounds of your appeal and any supporting documents to:' \
                      "</p>\n<ul class=\"govuk-list govuk-list--bullet\">\n  <li><a href=\"mailto:CRM7appeal" \
                      '@justice.gov.uk">CRM7appeal@justice.gov.uk</a>, with the LAA case reference in the subject of the ' \
                      "email</li>\n  <li>Nottingham Office, 3rd Floor B3.20, 1 Unity Square, Queensbridge Road, " \
                      "Nottingham NG2 1AW, or DX 10035 Nottingham 1</li>\n</ul>\n<p>Appeals may be considered by LAA " \
                      'caseworkers or sent to an independent costs assessor (ICA). You can only appeal once. The ICA’s ' \
                      "decision is final (as stated in the Criminal Bills Assessment Manual (CBAM) rule 4.4.1).</p>\n</p>"
              }
            ]
          )
        end
      end

      context 'with no adjustements' do
        let(:claim) { create(:claim, :part_granted_status, :firm_details, :updated_at, assessment_comment:) }

        it 'generates no links in text' do
          expect(subject.row_data).to match(
            [
              {
                head_key: 'application_status',
                text: '<p><strong class="govuk-tag govuk-tag--blue">Part Granted</strong></p>' \
                      '<p>1 December 2023</p><br><p>£0.00 claimed</p><p>£0.00 allowed</p>'
              },
              {
                head_key: 'laa_response',
                text: '<p>this is a comment</p><p>2nd line</p><p><ul class="govuk-list govuk-list--bullet"></ul></p><p>' \
                      "<h3 class=\"govuk-heading-s\">Appeal the adjustment</h3>\n<p>If you want to appeal the adjustment, " \
                      'email or post a detailed explanation of the grounds of your appeal and any supporting documents to:' \
                      "</p>\n<ul class=\"govuk-list govuk-list--bullet\">\n  <li><a href=\"mailto:CRM7appeal" \
                      '@justice.gov.uk">CRM7appeal@justice.gov.uk</a>, with the LAA case reference in the subject of the ' \
                      "email</li>\n  <li>Nottingham Office, 3rd Floor B3.20, 1 Unity Square, Queensbridge Road, " \
                      "Nottingham NG2 1AW, or DX 10035 Nottingham 1</li>\n</ul>\n<p>Appeals may be considered by LAA " \
                      'caseworkers or sent to an independent costs assessor (ICA). You can only appeal once. The ICA’s ' \
                      "decision is final (as stated in the Criminal Bills Assessment Manual (CBAM) rule 4.4.1).</p>\n</p>"
              }
            ]
          )
        end
      end

      context 'with adjustements' do
        let(:claim) do
          create(
            :claim,
            :part_granted_status,
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

          expect(all_text)
            .to match(%r{<a class="govuk-link.*" href=".*/steps/view_claim\?section=adjustments#work-items-tab">Review adjustments to work items</a>})
            .and match(%r{<a class="govuk-link.*" href=".*/steps/view_claim\?section=adjustments#letters-and-calls-tab">Review adjustments to letters and calls</a>})
            .and match(%r{<a class="govuk-link.*" href=".*/steps/view_claim\?section=adjustments#disbursements-tab">Review adjustments to disbursements</a>})
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
              text: Regexp.new('<p>this is a comment</p><p>2nd line</p>')
            }
          ]
        )
      end
    end
  end
end
