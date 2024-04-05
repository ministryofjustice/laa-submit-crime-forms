class SyncController < ApplicationController
  skip_before_action :authenticate_provider!
  skip_before_action :can_access_service

  def sync_all
    PullUpdates.new.perform
    head :ok
  end
end
