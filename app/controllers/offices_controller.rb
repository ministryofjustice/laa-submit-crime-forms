class OfficesController < ApplicationController
  def show
    redirect_to current_provider.multiple_offices? ? edit_path : post_save_path
  end

  def edit
    form = OfficeForm.new(provider: current_provider)
    render 'offices/edit', locals: { form:, update_path: }
  end

  def update
    form = OfficeForm.new(form_params.merge(provider: current_provider))
    if form.save
      redirect_to post_save_path
    else
      render 'offices/edit', locals: { form:, update_path: }
    end
  end

  def form_params
    params.require(:office_form).permit(:selected_office_code)
  end
end
