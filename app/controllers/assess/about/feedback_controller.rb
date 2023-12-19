# frozen_string_literal: true

module Assess
  module About
    class FeedbackController < Assess::ApplicationController
      def index
        @feedback = Feedback.new
      end

      def create
        @feedback = Feedback.new feedback_params
        if @feedback.valid?
          submit_feedback
          redirect_to assess_claims_path, notice: I18n.t('assess.feedback.submitted.success')
        else
          render 'index'
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
end
