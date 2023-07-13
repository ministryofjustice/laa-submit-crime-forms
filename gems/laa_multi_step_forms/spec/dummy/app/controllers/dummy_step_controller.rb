class DummyStepController < Steps::BaseStepController
  def show
    head(:ok)
  end

  def edit
    head(:ok)
  end

  def update
    return if DummyStepImplementation.skip_update

    update_and_advance(DummyStepImplementation.form_class, DummyStepImplementation.options)
  end

  def after_commit
    head(:ok)
  end

  private

  def current_application
    DummyStepImplementation.current_application
  end

  def authenticate_provider!
    true
  end

  def decision_tree_class
    DummyStepImplementation.decision_tree_class || super
  end
end
