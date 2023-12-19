require_relative '../../app/helpers/assess/form_builder_helper'

ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

GOVUKDesignSystemFormBuilder::FormBuilder.class_eval do
  include Assess::FormBuilderHelper
end
