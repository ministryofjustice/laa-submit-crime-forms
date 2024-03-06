require 'rails_helper'

RSpec.describe LaaMultiStepForms::ErrorsController, type: :controller do
  render_views

  it '#invalid_session' do
    get :invalid_session, params: { use_route: :laa_msf }

    expect(response).to be_ok
  end

  it '#application_not_found' do
    get :application_not_found, params: { use_route: :laa_msf }

    expect(response).to be_not_found
  end

  it '#not_found' do
    get :not_found, params: { use_route: :laa_msf }

    expect(response).to be_not_found
  end

  it '#unauthorized' do
    get :unauthorized, params: { use_route: :laa_msf }

    expect(response).to be_unauthorized
  end

  it '#not_enrolled' do
    get :not_enrolled, params: { use_route: :laa_msf }

    expect(response).to be_forbidden
  end

  it '#unhandled' do
    get :unhandled, params: { use_route: :laa_msf }

    expect(response).to have_http_status(:internal_server_error)
  end
end
