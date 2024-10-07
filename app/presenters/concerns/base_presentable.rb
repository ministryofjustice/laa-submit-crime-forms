module BasePresentable
  extend ActiveSupport::Concern

  def url_helper
    Rails.application.routes.url_helpers
  end
end
