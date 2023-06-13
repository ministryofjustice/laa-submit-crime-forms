require_relative '../../app/helpers/laa_multi_step_forms/form_builder_helper'
require_relative '../../app/lib/govuk_design_system_formbuilder/elements/period'
ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

GOVUKDesignSystemFormBuilder::FormBuilder.class_eval do
  include LaaMultiStepForms::FormBuilderHelper
end
