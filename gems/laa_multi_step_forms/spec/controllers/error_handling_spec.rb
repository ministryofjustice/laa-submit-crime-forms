require 'rails_helper'

RSpec.describe DummyStepController, type: :controller do
  #  when Errors::InvalidSession, ActionController::InvalidAuthenticityToken
  #         redirect_to laa_msf.invalid_session_errors_path
  #       when Errors::ApplicationNotFound

  let(:application) do
    double(:application, id: SecureRandom.uuid, navigation_stack: {}, 'navigation_stack=': true, save!: true)
  end
  let(:error_class) { nil }

  before do
    allow(DummyStepImplementation).to receive(:current_application).and_return(application)
    allow(DummyStepImplementation).to receive(:form_class).and_raise(error_class)
  end

  context 'when Errors::InvalidSession is raised' do
    let(:error_class) { Errors::InvalidSession }

    it 'redirects to the error contrller' do
      put :update, params: { id: application.id }

      expect(response).to redirect_to(controller.laa_msf.invalid_session_errors_path)
    end
  end

  context 'when ActionController::InvalidAuthenticityToken is raised' do
    let(:error_class) { ActionController::InvalidAuthenticityToken }

    it 'redirects to the error contrller' do
      put :update, params: { id: application.id }

      expect(response).to redirect_to(controller.laa_msf.invalid_session_errors_path)
    end
  end

  context 'when Errors::ApplicationNotFound is raised' do
    let(:error_class) { Errors::ApplicationNotFound }

    it 'redirects to the error contrller' do
      put :update, params: { id: application.id }

      expect(response).to redirect_to(controller.laa_msf.application_not_found_errors_path)
    end
  end

  context 'any other error class' do
    let(:error_class) { Class.new(StandardError) }

    context 'non production RAILS_ENV' do
      before do
        allow(ENV).to(receive(:[])).and_call_original
        allow(ENV).to(receive(:[])).with('RAILS_ENV').and_return('development')
      end

      it 'raises the error' do
        expect { put :update, params: { id: application.id } }.to raise_error(error_class)
      end
    end

    context 'production RAILS_ENV' do
      before do
        allow(ENV).to(receive(:[])).and_call_original
        allow(ENV).to(receive(:[])).with('RAILS_ENV').and_return('production')
        allow(ENV).to(receive(:[])).with('SENTRY_DSN').and_return('http://example.com')
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error)
        expect(Sentry).to receive(:capture_exception)

        put :update, params: { id: application.id }
      end

      it 'redirects to the error contrller' do
        put :update, params: { id: application.id }

        expect(response).to redirect_to(controller.laa_msf.unhandled_errors_path)
      end
    end
  end

  context 'application is present' do
    it 'does NOT redirects to the error contrller' do
      get :show, params: { id: SecureRandom.uuid }

      expect(response).not_to have_http_status(:redirect)
    end
  end

  context 'when application is not found' do
    let(:application) { nil }

    it 'redirects to the error contrller' do
      get :show, params: { id: SecureRandom.uuid }

      expect(response).to redirect_to(controller.laa_msf.application_not_found_errors_path)
    end
  end
end
