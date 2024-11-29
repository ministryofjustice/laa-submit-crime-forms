class SyncController < ApplicationController
  skip_before_action :authenticate_provider!
  skip_before_action :verify_authenticity_token, only: :sync_individual

  def sync_individual
    # Leave this stub here until we have finished updating the app store to stop
    # pinging this webhook url, so we don't get a bunch of errors
    head :ok
  end
end
