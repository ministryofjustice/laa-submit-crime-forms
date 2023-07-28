module RouteHelpers
  def edit_step(name, opts = {}, &block)
    resource name,
             only: opts.fetch(:only, [:edit, :update]),
             controller: name,
             path_names: { edit: '' } do
      yield if block
    end
  end

  def upload_step(name, opts = {})
    resource name,
             only: opts.fetch(:only, [:edit, :update, :create, :destroy]),
             controller: name,
             path_names: { edit: '' }
  end

  def crud_step(name, opts = {}, &block)
    edit_step name, only: [] do
      resources only: [:edit, :update, :destroy],
                except: opts.fetch(:except, []),
                controller: name, param: opts.fetch(:param),
                path_names: { edit: '' } do
        yield if block
        get :confirm_destroy, on: :member if parent_resource.actions.include?(:destroy)
      end
    end
  end

  def show_step(name)
    resource name, only: [:show], controller: name
  end
end
