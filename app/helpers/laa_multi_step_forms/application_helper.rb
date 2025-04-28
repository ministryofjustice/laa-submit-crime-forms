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
      case current_layout
      when 'nsm'
        t('nsm.service_name')
      when 'prior_authority'
        t('prior_authority.service_name')
      else
        t('service.name')
      end
    end

    def current_layout
      controller.send :_layout, lookup_context, [], []
    rescue NoMethodError # The above does not work in the context of PDF generation
      nil
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

      minutes = style == :minimal_html ? format('%02d', period % 60) : (period % 60)

      t("helpers.time_period.hours.#{style}", count: period / 60) +
        t("helpers.time_period.minutes.#{style}", count: period % 60, minutes: minutes)
    end

    def gbp_field_value(value)
      return value if value.is_a?(String)

      number_with_precision(value, precision: 2, delimiter: ',')
    end

    # rubocop:disable Metrics/ParameterLists
    def suggestion_select(form, field, values, id_field, value_field, data_module = 'accessible-autocomplete', *,
                          data: {}, **)
      data[:module] = data_module
      data[:name] = "#{form.object_name}[#{field}_suggestion]"

      value = form.object[field]

      # as the values ID can be a symbol or a string we check on both instead
      # of converting the keys as this is easier
      if value && !values.map(&id_field).intersect?([value, value.to_sym].compact)
        values = values.dup.unshift(fake_record(id_field, value_field, value))
      end

      form.govuk_collection_select(field, values, id_field, value_field, *, data:, **)
    end
    # rubocop:enable Metrics/ParameterLists

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
