# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class ApplicationStatusCard < Base
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper
      attr_reader :claim

      def initialize(claim)
        @claim = claim
        @group = 'application_status'
        @section = 'application_status'
      end

      def row_data
        response = status == 'submitted' ? nil : '<p>Fake LAA Response</p>'
        links = join_strings(*edit_links, *appeal_button)
        [
          {
            head_key: 'application_status',
            text: ApplicationController.helpers.sanitize(status_text, tags: %w[strong br p])
          },
          ({
            head_key: 'laa_response',
            text: ApplicationController.helpers.sanitize(response, tags: %w[p]) + ApplicationController.helpers.sanitize(links, tags: %w[ul li a p])
          } if response)
          ].compact
      end

      private

      def status_text
        if status == 'submitted'
          join_strings(status_tag(status), submitted_data, translate(:awaiting_review), tag.br, claimed_amount)
        else
          join_strings(status_tag(status), submitted_data, tag.br, claimed_amount, allowed_amount(status))
        end
      end

      def status
        return 'part_grant'
        @status ||= claim.status.in?(%w[submitted part_grant rejected]) ? claim.status : 'granted'
      end

      def join_strings(*strings)
        strings.map { |str| str == tag.br ? str : "<p>#{str}</p>" }.join
      end

      def claimed_amount
        "#{NumberTo.pounds(total_gross)} claimed"
      end

      def total_gross
        @total_gross ||= Nsm::CostSummary::Summary.new(claim).total_gross
      end

      # TODO: calculate this amount
      def allowed_amount(status)
        return '£0.00 allowed' if status == 'rejected'
        return "#{NumberTo.pounds(total_gross)} allowed" if status == 'granted'

        'Pending Data'
      end

      def translate(key)
        I18n.t("nsm.steps.check_answers.groups.#{group}.#{section}.#{key}")
      end

      def status_tag(status)
        "<strong class=\"govuk-tag #{I18n.t("nsm.claims.index.status_colour.#{claim.status}")}\">" \
            "#{I18n.t("nsm.claims.index.status.#{claim.status}")}</strong>".html_safe
      end

      def submitted_data
        claim.updated_at&.to_fs(:stamp)
      end

      def appeal_button
        return [] unless status.in?(%w[part_grant rejected])

        helper = Rails.application.routes.url_helpers
        [
          govuk_button_link_to(
            translate('appeal'),
            helper.url_for(controller: "nsm/steps/view_claim", action: :show, id: claim.id, only_path: true),
            class: 'govuk-!-margin-bottom-0'
          )
        ]
      end

      def edit_links
        return [] unless status == 'part_grant'

        helper = Rails.application.routes.url_helpers
        li_elements = %w[work_items letters_and_calls disbursements].map do |type|
          tag.li do
            govuk_link_to(
              translate(type),
              helper.url_for(controller: "nsm/steps/view_claim", action: :show, id: claim.id, section: 'adjustments', anchor: type, only_path: true),
              class: 'govuk-link--no-visited-state'
            )
          end if any?(type)
        end
        tag.ul ApplicationController.helpers.sanitize(li_elements.join, tags: %w[a li]), class: 'govuk-list govuk-list--bullet'
      end

      # TODO: implement logic here to check for changes
      def any?(type)
        case type
        when 'work_items'
          true
        when 'letters_and_calls'
          true
        when 'disbursements'
          true
        end
      end
    end
  end
end
