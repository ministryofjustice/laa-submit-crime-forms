# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class ApplicationStatusCard < Base
      EMAIL = 'magsbilling@justice.gov.uk'
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::OutputSafetyHelper
      attr_reader :claim

      def status
        claim.status.inquiry
      end

      def initialize(claim)
        @claim = claim
        @group = 'application_status'
        @section = 'application_status'
      end

      def row_data
        [
          {
            head_key: 'application_status',
            text: status_text
          },
          (if response.any?
             {
               head_key: 'laa_response',
               text: join_strings(*response, *edit_links, *appeal_button, *update_claim)
             }
           end)
        ].compact
      end

      private

      def sanitize(value, tags: [])
        ApplicationController.helpers.sanitize(value, tags:)
      end

      def status_text
        items = [status_tag(status), submitted_date]
        if status.submitted?
          items += [translate(:awaiting_review), tag.br, claimed_amount]
        else
          items += [tag.br, claimed_amount]
          items += [allowed_amount(status)] unless status.further_info? || status.provider_requested? || status.review?
        end
        join_strings(*items)
      end

      def join_strings(*strings)
        safe_join(strings.compact.map { |str| str == tag.br ? str : tag.p(str) })
      end

      def claimed_amount
        "#{NumberTo.pounds(total_gross)} claimed"
      end

      def total_gross
        @total_gross ||= Nsm::CostSummary::Summary.new(claim).total_gross
      end

      def translate(key)
        I18n.t("nsm.steps.check_answers.groups.#{group}.#{section}.#{key}")
      end

      def status_tag(status)
        tag.strong(
          I18n.t("nsm.claims.index.status.#{status}"),
          class: ['govuk-tag', I18n.t("nsm.claims.index.status_colour.#{status}")]
        )
      end

      def submitted_date
        claim.updated_at.to_fs(:stamp)
      end

      def appeal_button
        return [] unless status.part_grant? || status.rejected?

        helper = Rails.application.routes.url_helpers
        [
          govuk_button_link_to(
            translate('appeal'),
            helper.url_for(controller: 'nsm/steps/view_claim', action: :show, id: claim.id, only_path: true),
            class: 'govuk-!-margin-bottom-0'
          )
        ]
      end

      def edit_links
        return [] unless status.part_grant?

        helper = Rails.application.routes.url_helpers
        li_elements = %w[work_items letters_and_calls disbursements].map do |type|
          next unless any_changes?(type)

          tag.li do
            govuk_link_to(
              translate(type),
              helper.url_for(controller: 'nsm/steps/view_claim', action: :show, id: claim.id, section: 'adjustments',
                             anchor: type, only_path: true),
              class: 'govuk-link--no-visited-state'
            )
          end
        end
        tag.ul safe_join(li_elements), class: 'govuk-list govuk-list--bullet'
      end

      def update_claim
        return [] unless status.further_info? || status.provider_requested? || status.review?

        key = status.provider_requested? ? 'update_provider_requested' : 'update_further_info'
        email = tag.a(EMAIL, href: "mailto:#{EMAIL}")
        [
          tag.span(translate('update_claim'), class: 'govuk-!-font-weight-bold'),
          translate(key).sub('%email%', email).html_safe
        ].compact
      end

      def response
        @response ||= begin
          if status.granted?
            [I18n.t('nsm.steps.view_claim.granted_response')]
          elsif status.part_granted? || status.rejected?
            response_text = claim.assessment_comment
            response_text.split("\n").map { sanitize(_1) }
          else
            []
          end
        end
      end

      def allowed_amount(status)
        return '£0.00 allowed' if status.rejected?
        return "#{NumberTo.pounds(total_gross)} allowed" if status.granted?

        'Pending Data'
      end

      def any_changes?(type)
        case type
        when 'work_items'
          claim.work_items.any?
        when 'letters_and_calls'
          claim
        else # 'disbursements'
          true
        end
      end
    end
  end
end
