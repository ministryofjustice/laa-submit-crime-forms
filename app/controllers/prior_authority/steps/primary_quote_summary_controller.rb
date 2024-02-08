module PriorAuthority
  module Steps
    class PrimaryQuoteSummaryController < BaseController
      def show
        @model = PriorAuthority::PrimaryQuoteSummary.new(current_application)
      end
    end
  end
end
