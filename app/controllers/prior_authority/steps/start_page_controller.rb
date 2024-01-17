module PriorAuthority
  module Steps
    class StartPageController < BaseController
      include ApplicationHelper
      include CookieConcern
      layout 'prior_authority'

      before_action :set_default_cookies

      def show
        @model = current_provider.prior_authority_applications.find(params[:id])
      end
    end
  end
end
