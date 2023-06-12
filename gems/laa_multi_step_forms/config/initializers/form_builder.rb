require_relative '../../app/helpers/laa_multi_step_forms/form_builder_helper'
require_relative '../../app/lib/govuk_design_system_formbuilder/elements/period.rb'
ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

GOVUKDesignSystemFormBuilder::FormBuilder.class_eval do
  include LaaMultiStepForms::FormBuilderHelper

  def govuk_period_field(attribute_name, hint: {}, legend: {}, caption: {}, fields: {}, maxlength_enabled: false, form_group: {}, **kwargs, &block)
    GOVUKDesignSystemFormBuilder::Elements::Period.new(self, object_name, attribute_name, hint: hint, legend: legend, caption: caption, fields: fields, maxlength_enabled: maxlength_enabled, form_group: form_group, **kwargs, &block).html
  end
end
