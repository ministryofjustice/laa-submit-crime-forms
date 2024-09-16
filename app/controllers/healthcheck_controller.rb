# frozen_string_literal: true

class HealthcheckController < ApplicationController
  skip_before_action :authenticate_provider!

  def ping
    render json: build_args, status: :ok
  end

  def ready
    # A pod is only ready for traffic once the Clamby container attached to it
    # is able to scan files. So by scanning a file that will always be there
    # and is known to be safe, we trigger an error if Clamby isn't ready,
    # causing this endpoint to return a 503, telling K8s that the pod
    # isn't ready yet.
    return head :service_unavailable unless Clamby.safe?(Rails.root.join('Gemfile'))

    render json: build_args, status: :ok
  rescue Clamby::ClamscanClientError
    head :service_unavailable
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
