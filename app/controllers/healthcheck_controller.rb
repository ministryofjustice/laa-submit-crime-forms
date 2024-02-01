# frozen_string_literal: true

class HealthcheckController < ApplicationController
  skip_before_action :authenticate_provider!
  skip_before_action :can_access_service

  def ping
    render json: build_args, status: :ok
  end

  private

  def build_args
    {
      branch_name: ENV.fetch('APP_BRANCH_NAME', nil),
      build_date: ENV.fetch('APP_BUILD_DATE', nil),
      build_tag: ENV.fetch('APP_BUILD_TAG', nil),
      commit_id: ENV.fetch('APP_GIT_COMMIT', nil)
    }
  end
end
