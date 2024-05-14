module Nsm
  module SupportingEvidence
    class CheckList
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TranslationHelper

      # govuk_link_to required modules
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper

      attr_reader :claim

      def initialize(claim)
        @claim = claim
      end

      def self.render(claim)
        new(claim).render
      end

      def render
        tag.ul safe_join(items), class: 'govuk-list govuk-list--bullet govuk-!-margin-bottom-6 govuk-!-padding-left-6'
      end

      def items
        return @items if @items.present?

        @items = []
        @items << li_crm8_form_link if assigned_counsel?
        @items << li_for_translation('remittal') if remitted_to_magistrate?
        @items << li_for_translation('supplemental') if supplemental_claim?
        @items << li_for_translation('authority') if any_prior_authority?
        # TODO: wasted_costs; CRM457-1464 and CRM457-1384
        @items
      end

      private

      def li_crm8_form_link
        tag.li do
          govuk_link_to(
            t('crm8', scope: i18n_scope),
            'https://www.gov.uk/government/publications/crm8-assigned-counsels-fee-note',
            class: 'govuk-link--no-visited-state',
            target: '_blank'
          )
        end
      end

      def li_for_translation(key)
        tag.li(t(key, scope: i18n_scope))
      end

      def i18n_scope
        'nsm.steps.supporting_evidence.content.para1'
      end

      def assigned_counsel?
        claim.assigned_counsel == 'yes'
      end

      def remitted_to_magistrate?
        claim.remitted_to_magistrate == 'yes'
      end

      def supplemental_claim?
        claim.supplemental_claim == 'yes'
      end

      def any_prior_authority?
        claim.disbursements.any? { |disbursement| disbursement.prior_authority == 'yes' }
      end
    end
  end
end
