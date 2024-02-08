module AddAnotherMethods
  extend ActiveSupport::Concern

  included do
    before_action :build_new_record, only: %i[new create]
    before_action :build_edit_record, only: %i[edit update confirm_delete destroy]

    attr_accessor :record
  end
  def new
    build_form_object
    render :edit
  end

  def edit
    build_form_object
  end

  def create
    persist
  end

  def update
    persist
  end

  def confirm_delete
    build_form_object
  end

  def destroy
    record.destroy
    redirect_to decision_tree_class.new(build_form_object, as:).destination.merge(deleted: true)
  end

  private

  def build_new_record
    @record = object_collection.new
  end

  def build_edit_record
    @record = object_collection.find(params[:id])
  end

  def reload
    render :edit
  end

  # :nocov:
  def build_form_object
    raise 'Implement in subclass'
  end

  def persist
    raise 'Implement in subclass'
  end

  def object_collection
    raise 'Implement in subclass'
  end

  def as
    raise 'Implement in subclass'
  end

  def redirect_to_current_object
    raise 'Implement in subclass'
  end
  # :nocov:
end
