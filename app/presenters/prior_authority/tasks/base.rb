module PriorAuthority
  module Tasks
    class Base < ::Tasks::Generic
      # govuk_link_to required modules
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper
      DECISION_TREE = Decisions::DecisionTree

      def default_url_options
        { application_id: application }
      end

      def section_link
        govuk_link_to(section_text, section_url)
      end

      private

      def section_text
        I18n.t("tasklist.task.prior_authority/#{key}")
      end

      def section_url(_params = nil)
        public_send("edit_prior_authority_steps_#{key}_path", application)
      end
    end
  end
end
