# frozen_string_literal: true

module Nsm
  module CheckAnswers
    # rubocop:disable Metrics/ClassLength
    class ApplicationStatusCard < Base
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::OutputSafetyHelper

      attr_reader :claim

      def initialize(claim, skip_links: false)
        @claim = claim
        @skip_links = skip_links
        @group = 'application_status'
        @section = 'application_status'
        super()
      end

      def row_data
        [
          {
            head_key: 'application_status',
            text: state_text
          },
          (if response.any?
             {
               head_key: 'laa_response',
               text: join_strings(*response, *edit_links, appeal_info,
                                  *(claim.sent_back? && !claim.pending_further_information ? update_claim : []))
             }
           end)
        ].compact
      end

      private

      def state_text
        items = [state_tag, submitted_date]
        if claim.submitted? || claim.provider_updated?
          items += [translate(:awaiting_review), tag.br, claimed_amount]
        else
          items += [tag.br, claimed_amount]
          items += [allowed_amount] unless claim.sent_back? || claim.expired?
        end
        join_strings(*items)
      end

      def join_strings(*strings)
        safe_join(strings.compact.map { |str| str == tag.br || str.include?('</h3>') ? str : tag.p(str) })
      end

      def claimed_amount
        "#{NumberTo.pounds(total_gross)} claimed"
      end

      delegate :show_adjusted?, to: :claim

      def total_gross
        claim.totals[:totals][:claimed_total_inc_vat]
      end

      def total_gross_allowed
        claim.totals[:totals][:assessed_total_inc_vat]
      end

      def translate(key)
        I18n.t("nsm.steps.check_answers.groups.#{group}.#{section}.#{key}")
      end

      def state_tag
        tag.strong(
          I18n.t("nsm.claims.index.state.#{claim.state}"),
          class: ['govuk-tag', I18n.t("nsm.claims.index.state_colour.#{claim.state}")]
        )
      end

      def submitted_date
        claim.updated_at.to_fs(:stamp)
      end

      def appeal_info
        return unless claim.part_grant? || claim.rejected?

        ApplicationController.new.render_to_string(partial: 'nsm/steps/view_claim/appeal', locals: { state: claim.state })
      end

      def edit_links
        return [] if @skip_links
        return expiry_links if claim.expired?
        return unless claim.part_grant?

        li_elements = %w[work_items letters_and_calls disbursements additional_fees].map do |type|
          next unless any_changes?(type)

          tag.li do
            govuk_link_to(
              translate(type),
              url_helper.url_for(controller: 'nsm/steps/view_claim',
                                 action: "adjusted_#{type}",
                                 id: claim.id,
                                 anchor: 'cost-summary-table',
                                 only_path: true),
              class: 'govuk-link--no-visited-state'
            )
          end
        end
        tag.ul safe_join(li_elements), class: 'govuk-list govuk-list--bullet'
      end

      def expiry_links
        tag.ul(class: 'govuk-list') do
          tag.li do
            govuk_link_to(translate('requested_claim_update'), '#further_information')
          end
        end
      end

      def update_claim
        rfi_email = Rails.configuration.x.contact.nsm_rfi_email
        email = tag.a(rfi_email, href: "mailto:#{rfi_email}")
        [
          tag.span(translate('update_claim'), class: 'govuk-!-font-weight-bold'),
          translate('update_further_info').sub('%email%', email).html_safe
        ].compact
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def response
        @response ||= if claim.submitted? || claim.provider_updated?
                        []
                      elsif claim.granted? && claim.assessment_comment.blank?
                        [I18n.t('nsm.steps.view_claim.granted_response')]
                      elsif claim.expired?
                        expiry_response
                      elsif claim.sent_back? && claim.pending_further_information.present?
                        further_information_response + [update_claim_button]
                      else
                        claim.assessment_comment.split("\n")
                      end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def expiry_response
        I18n.t('nsm.steps.view_claim.expiry_explanations',
               requested: further_information.requested_at.to_fs(:stamp),
               deadline: tag.strong(resubmission_deadline_text)).map(&:html_safe)
      end

      def further_information_response
        I18n.t('nsm.steps.view_claim.further_information_response',
               deadline:
                 tag.strong(resubmission_deadline_text)).map(&:html_safe) + further_information.information_requested.split("\n")
      end

      def allowed_amount
        return '£0.00 allowed' if claim.rejected?
        return "#{NumberTo.pounds(total_gross_allowed)} allowed" if show_adjusted?

        "#{NumberTo.pounds(total_gross)} allowed"
      end

      def any_changes?(type)
        case type
        when 'work_items'
          claim.work_items.any?(&:adjustment_comment)
        when 'letters_and_calls'
          claim.letters_adjustment_comment || claim.calls_adjustment_comment
        when 'disbursements'
          claim.disbursements.any?(&:adjustment_comment)
        else # additional fees (youth court fee)
          claim.youth_court_fee_adjustment_comment
        end
      end

      def further_information
        # If a claim is expired, the most recent further information that we want to reference won't be pending
        claim.pending_further_information || claim.further_informations.order(:requested_at).last
      end

      def update_claim_button
        govuk_button_link_to(
          I18n.t('nsm.steps.view_claim.update_claim'),
          url_helper.edit_nsm_steps_further_information_path(claim)
        )
      end

      def resubmission_deadline_text
        further_information.resubmission_deadline.to_fs(:stamp)
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
