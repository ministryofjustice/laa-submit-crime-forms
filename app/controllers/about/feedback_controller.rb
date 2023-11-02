# frozen_string_literal: true

module About
  class FeedbackController < ApplicationController
    def index
      @feedback = Feedback.new
    end

    def create
      @feedback = Feedback.new feedback_params
      if @feedback.valid?
        submit_feedback
        redirect_to provider_signed_in? ? applications_path : root_path, notice: I18n.t('feedback.submitted.success')
      else
        render about_feedback_index_path
      end
    end

    private

    def submit_feedback
      FeedbackMailer.notify(
        user_email: feedback_params[:user_email],
        user_rating: feedback_params[:user_rating],
        user_feedback: feedback_params[:user_feedback],
        application_env: application_environment
      ).deliver_later!
    end

    def feedback_params
      params.require(:feedback).permit(:user_feedback, :user_email, :user_rating)
    end

    def application_environment
      ENV.fetch('ENV', Rails.env).to_s
    end
  end
end
