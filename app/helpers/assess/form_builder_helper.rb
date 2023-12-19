require_relative '../../../gems/laa_multi_step_forms/app/lib/govuk_design_system_formbuilder/elements/period'

module Assess
  module FormBuilderHelper
    # :nocov:
    # rubocop:disable Metrics/ParameterLists
    def govuk_period_field(attribute_name, hint: {}, legend: {}, caption: {}, widths: {}, maxlength_enabled: false,
                           form_group: {}, **, &block)
      GOVUKDesignSystemFormBuilder::Elements::Period.new(
        self, object_name, attribute_name,
        hint:, legend:, caption:, widths:, maxlength_enabled:, form_group:, **, &block
      ).html
    end
    # rubocop:enable Metrics/ParameterLists
    # :nocov:
  end
end
