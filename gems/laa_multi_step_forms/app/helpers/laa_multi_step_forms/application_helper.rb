module LaaMultiStepForms
  module ApplicationHelper
    def current_application
      raise 'implement this action, in subclasses'
    end

    def title(page_title)
      content_for(
        :page_title, [page_title.presence, service_name, 'GOV.UK'].compact.join(' - ')
      )
    end

    # In local/test we raise an exception, so we are aware a title has not been set
    def fallback_title
      exception = StandardError.new("page title missing: #{controller_name}##{action_name}")
      raise exception if Rails.application.config.consider_all_requests_local

      title ''
    end

    def service_name
      t('service.name')
    end

    def app_environment
      "app-environment-#{ENV.fetch('ENV', 'local')}"
    end

    def format_period(period)
      return t('helpers.time_period.missing') if period.nil?

      t("helpers.time_period.hours", count: period / 60) +
        t("helpers.time_period.minutes", count: period % 60)
    end
  end
end
