class DummyStepController < ::Steps::BaseStepController
  def show
    head(:ok)
  end

  def edit
    head(:ok)
  end

  def update
    update_and_advance(DummyStepImplementation.form_class, DummyStepImplementation.options)
  end

  def after_commit
    head(:ok)
  end

  private

  def subsequent_steps
    ['step_after_dummy']
  end

  def current_application
    DummyStepImplementation.current_application
  end

  def authenticate_provider!
    true
  end

  def decision_tree_class
    DummyStepImplementation.decision_tree_class || super
  end

  def do_not_add_to_viewed_steps
    DummyStepImplementation.do_not_add_to_viewed_steps || super
  end
end
