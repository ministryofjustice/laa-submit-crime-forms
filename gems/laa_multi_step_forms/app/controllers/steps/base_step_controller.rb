module Steps
  class BaseStepController < ::ApplicationController
    before_action :check_application_presence
    before_action :prune_navigation_stack, only: [:update]
    before_action :append_navigation_stack, only: [:show, :edit, :update]

    # :nocov:
    def show
      raise 'implement this action, if needed, in subclasses'
    end

    def edit
      raise 'implement this action, if needed, in subclasses'
    end

    def update
      raise 'implement this action, if needed, in subclasses'
    end
    # :nocov:

    private

    def decision_tree_class
      raise 'implement this action, in subclasses'
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def update_and_advance(form_class, opts = {})
      hash = permitted_params(form_class).to_h
      record = opts[:record]

      @form_object = form_class.new(
        hash.merge(application: current_application, record: record)
      )

      if params.key?(:commit_draft)
        # Validations will not be run when saving a draft
        @form_object.save!
        redirect_to after_commit_path(id: current_application.id)
      elsif params.key?(:save_and_refresh)
        @form_object.save!
        render opts.fetch(:render, :edit)
      elsif @form_object.save
        redirect_to decision_tree_class.new(@form_object, as: opts.fetch(:as)).destination, flash: opts[:flash]
      else
        render opts.fetch(:render, :edit)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def permitted_params(form_class)
      params
        .fetch(form_class.model_name.singular, {})
        .permit(form_class.attribute_names + additional_permitted_params)
    end

    # Some form objects might contain complex attribute structures or nested params.
    # Override in subclasses to declare any additional parameters that should be permitted.
    def additional_permitted_params
      []
    end

    def prune_navigation_stack
      current_application.navigation_stack =
        current_application.navigation_stack.take_while { |path| path != request.fullpath }
      current_application.save!(touch: false)
    end

    def append_navigation_stack
      current_application.navigation_stack |= [request.fullpath]
      current_application.save!(touch: false)
    end
  end
end
