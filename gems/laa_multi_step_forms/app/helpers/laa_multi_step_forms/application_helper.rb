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

    def phase_name
      return t('layouts.phase_banner.phase') if ENV.fetch('ENV', 'local') == 'production'

      ENV.fetch('ENV', 'local').capitalize
    end

    def format_period(period, style: :short)
      return period if period.blank?

      minutes = style == :minimal_html ? format('%02d', (period % 60)) : (period % 60)

      t("helpers.time_period.hours.#{style}", count: period / 60) +
        t("helpers.time_period.minutes.#{style}", count: period % 60, minutes: minutes)
    end

    def gbp_field_value(value)
      return value if value.is_a?(String)

      number_with_precision(value, precision: 2, delimiter: ',')
    end

    def suggestion_select(form, field, values, id_field, value_field, data_module = 'accessible-autocomplete', *,
                          data: {}, **)
      data[:module] = data_module
      data[:name] = "#{form.object_name}[#{field}_suggestion]"

      value = form.object[field]
      unless values.map(&id_field).include?(value)
        values = values.dup.unshift(fake_record(id_field, value_field, value))
      end

      form.govuk_collection_select(field, values, id_field, value_field, *, data:, **)
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
