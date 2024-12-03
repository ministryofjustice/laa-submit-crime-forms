module Steps
  class BaseStepController < ::ApplicationController
    before_action :check_application_presence
    before_action :prune_viewed_steps, only: [:update]
    before_action :update_viewed_steps, only: [:show, :edit]

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

    def reload
      @form_object.valid?
      render :edit
    end

    private

    def decision_tree_class
      raise 'implement this action, in subclasses'
    end

    def update_and_advance(form_class, opts = {})
      hash = permitted_params(form_class).to_h
      record = opts.fetch(:record, current_application)
      @form_object = form_class.new(
        hash.merge(application: current_application, record: record)
      )

      current_application.with_lock do
        process_form(@form_object, opts)
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def process_form(form_object, opts)
      if params.key?(:commit_draft)
        # Validations will not be run when saving a draft
        form_object.save!
        redirect_to opts[:after_commit_redirect_path] || nsm_after_commit_path(id: current_application.id)
      elsif params.key?(:reload)
        reload
      elsif params.key?(:save_and_refresh)
        form_object.save!
        redirect_to_current_object
      elsif form_object.save
        redirect_to decision_tree_class.new(form_object, as: opts.fetch(:as)).destination, flash: opts[:flash]
      else
        render opts.fetch(:render, :edit)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # This deals with the case when it is called from the NEW_RECORD endpoint
    # to avoid creating a new record on each click
    def redirect_to_current_object
      path_params = { id: @form_object.application.id }
      unless @form_object.application == @form_object.record
        sub_id_name = :"#{@form_object.record.class.to_s.underscore}_id"
        path_params[sub_id_name] = @form_object.record.id
      end

      redirect_to path_params
    end

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

    # :nocov:
    def subsequent_steps
      []
    end
    # :nocov:

    def prune_viewed_steps
      return if do_not_add_to_viewed_steps

      # filter out all steps that come after the current steps
      # from the list of viewed steps, to mark that those
      # steps need re-doing
      current_application.viewed_steps -= subsequent_steps

      # make sure the current location is included
      current_application.viewed_steps |= [controller_name]
      current_application.save!(touch: false)
    end

    def update_viewed_steps
      return if do_not_add_to_viewed_steps

      current_application.viewed_steps |= [controller_name]
      current_application.save!(touch: false)
    end

    # Overwrite this when controller shouldn't be in the stack (i.e. delete endpoints)
    def do_not_add_to_viewed_steps
      false
    end
  end
end
