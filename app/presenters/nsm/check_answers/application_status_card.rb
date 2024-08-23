# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class ApplicationStatusCard < Base
      EMAIL = 'CRM7fi@justice.gov.uk'
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::OutputSafetyHelper
      attr_reader :claim

      def initialize(claim)
        @claim = claim
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
          items += [allowed_amount] unless claim.sent_back?
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
        @cost_summary ||= Nsm::CostSummary::Summary.new(claim)
      end

      delegate :total_gross, :total_gross_allowed, to: :cost_summary

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
        return [] unless claim.part_grant?

        helper = Rails.application.routes.url_helpers
        li_elements = %w[work_items letters_and_calls disbursements].map do |type|
          next unless any_changes?(type)

          tab_anchor = safe_join([type.dasherize, 'tab'], '-')
          tag.li do
            govuk_link_to(
              translate(type),
              helper.url_for(controller: 'nsm/steps/view_claim', action: :show, id: claim.id, section: 'adjustments',
                             anchor: tab_anchor, only_path: true),
              class: 'govuk-link--no-visited-state'
            )
          end
        end
        tag.ul safe_join(li_elements), class: 'govuk-list govuk-list--bullet'
      end

      def update_claim
        return [] unless claim.sent_back?

        key = 'update_further_info'
        email = tag.a(EMAIL, href: "mailto:#{EMAIL}")
        [
          tag.span(translate('update_claim'), class: 'govuk-!-font-weight-bold'),
          translate(key).sub('%email%', email).html_safe
        ].compact
      end

      def response
        @response ||= if claim.submitted?
                        []
                      elsif claim.granted? && claim.assessment_comment.blank?
                        [I18n.t('nsm.steps.view_claim.granted_response')]
                      else
                        claim.assessment_comment.split("\n")
                      end
      end

      def allowed_amount
        return '£0.00 allowed' if claim.rejected?
        return "#{NumberTo.pounds(total_gross_allowed)} allowed" if claim.part_grant?

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
    end
  end
end
