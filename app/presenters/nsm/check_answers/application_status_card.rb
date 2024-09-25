# frozen_string_literal: true

module Nsm
  module CheckAnswers
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
               text: join_strings(*response, *edit_links, appeal_info, *update_claim)
             }
           end)
        ].compact
      end

      private

      def state_text
        items = [state_tag, submitted_date]
        if claim.submitted?
          items += [translate(:awaiting_review), tag.br, claimed_amount]
        else
          items += [tag.br, claimed_amount]
          items += [allowed_amount] unless claim.sent_back? || claim.expired?
        end
        join_strings(*items)
      end

      def join_strings(*strings)
        safe_join(strings.compact.map { |str| str == tag.br ? str : tag.p(str) })
      end

      def claimed_amount
        "#{NumberTo.pounds(total_gross)} claimed"
      end

      def cost_summary
        @cost_summary ||= Nsm::CheckAnswers::CostSummaryCard.new(claim, show_adjustments: true)
      end
      delegate :total_gross, :total_gross_allowed, :show_adjusted?, to: :cost_summary

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

        helper = Rails.application.routes.url_helpers
        li_elements = %w[work_items letters_and_calls disbursements].map do |type|
          next unless any_changes?(type)

          tag.li do
            govuk_link_to(
              translate(type),
              helper.url_for(controller: 'nsm/steps/view_claim',
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
        return [] unless claim.sent_back?

        rfi_email = Rails.configuration.x.contact.nsm_rfi_email
        email = tag.a(rfi_email, href: "mailto:#{rfi_email}")
        [
          tag.span(translate('update_claim'), class: 'govuk-!-font-weight-bold'),
          translate('update_further_info').sub('%email%', email).html_safe
        ].compact
      end

      def response
        @response ||= if claim.submitted?
                        []
                      elsif claim.granted? && claim.assessment_comment.blank?
                        [I18n.t('nsm.steps.view_claim.granted_response')]
                      elsif claim.expired?
                        expiry_response
                      elsif claim.sent_back? && FeatureFlags.nsm_rfi_loop.enabled?
                        further_information_response
                      else
                        claim.assessment_comment.split("\\n")
                      end
      end

      def expiry_response
        I18n.t('nsm.steps.view_claim.expiry_explanations',
               requested: claim.pending_further_information.requested_at.to_fs(:stamp),
               deadline: claim.pending_further_information.resubmission_deadline.to_fs(:stamp))
      end

      def further_information_response
          ApplicationController.helpers.sanitize_strings(I18n.t('nsm.steps.view_claim.further_information_response',
                deadline: further_information.resubmission_deadline.to_fs(:stamp)), %[strong]) +
          further_information.information_requested.split("\\n")
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
        else # 'disbursements'
          claim.disbursements.any?(&:adjustment_comment)
        end
      end

      def further_information
        claim.further_informations.last
      end
    end
  end
end
