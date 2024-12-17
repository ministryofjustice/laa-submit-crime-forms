# This module gets mixed in and extends the helpers already provided by
# `GOVUKDesignSystemFormBuilder::FormBuilder`. These are app-specific
# form helpers so can be coupled to application business and logic.
#
require_relative '../../lib/govuk_design_system_formbuilder/elements/period'

module LaaMultiStepForms
  module FormBuilderHelper
    # rubocop:disable Metrics/ParameterLists
    def govuk_period_field(attribute_name, hint: {}, legend: {}, caption: {}, widths: {}, maxlength_enabled: false,
                           form_group: {}, **, &block)
      GOVUKDesignSystemFormBuilder::Elements::Period.new(
        self, object_name, attribute_name,
        hint:, legend:, caption:, widths:, maxlength_enabled:, form_group:, **, &block
      ).html
    end

    def govuk_fully_validatable_date_field(attribute_name, hint: {}, legend: {}, caption: {}, date_of_birth: false,
                                           omit_day: false, maxlength_enabled: false, form_group: {}, **, &block)
      segments = { day: '3', month: '2', year: '1' }
      GOVUKDesignSystemFormBuilder::Elements::Date.new(
        self, object_name, attribute_name,
        segments:, hint:, legend:, caption:, date_of_birth:, omit_day:, maxlength_enabled:, form_group:, **, &block
      ).html
    end
    # rubocop:enable Metrics/ParameterLists

    def refresh_button(button: :update_calculation, opts: {})
      submit_button(button, opts.merge(secondary: true, name: 'save_and_refresh'))
    end

    def reload_button(button: :update_calculation, opts: {})
      submit_button(button, opts.merge(secondary: true, name: 'reload'))
    end

    def continue_button(primary: :save_and_continue, secondary: :save_and_come_back_later,
                        primary_opts: {}, secondary_opts: {})
      submit_button(primary, primary_opts) do
        submit_button(secondary, secondary_opts.merge(secondary: true, name: 'commit_draft')) if secondary
      end
    end

    def submit_button(i18n_key, opts = {}, &block)
      govuk_submit I18n.t("helpers.submit.#{i18n_key}"), **opts, &block
    end
  end
end
