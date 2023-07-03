module Decisions
  class BaseDecisionTree
    class InvalidStep < RuntimeError; end

    attr_reader :form_object, :step_name

    def initialize(form_object, as:)
      @form_object = form_object
      @step_name = as
    end

    def destination
      raise 'implement this action, in subclasses'
    end

    delegate :application, to: :form_object

    private

    # :nocov:
    def index(step_controller, params = {})
      { controller: step_controller, action: :index }.merge(params)
    end

    def show(step_controller, params = {})
      url_options(step_controller, :show, params)
    end

    def edit(step_controller, params = {})
      url_options(step_controller, :edit, params)
    end

    def url_options(controller, action, params = {})
      { controller: controller, action: action, id: application }.merge(params)
    end
    # :nocov:
  end
end
