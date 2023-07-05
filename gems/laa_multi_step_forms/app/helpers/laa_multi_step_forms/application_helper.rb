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

      t('helpers.time_period.hours', count: period / 60) +
        t('helpers.time_period.minutes', count: period % 60)
    end

    def suggestion_select(form, field, values, id_field, value_field, *args, data: {}, **kwargs)
      data[:module] = 'accessible-autocomplete'
      data[:name] = "#{form.object_name}[#{field}_suggestion]"

      value = form.object[field]
      unless values.map(&id_field).include?(value)
        values = values.dup.unshift(fake_record(id_field, value_field, value))
      end

      form.govuk_collection_select(field, values, id_field, value_field, *args, data:, **kwargs)
    end

    private

    def fake_record(id_field, value_field, value)
      if id_field == value_field
        Struct.new(id_field).new(value)
      else
        Struct.new(id_field, value_field).new(value, value)
      end
    end
  end
end
