module Nsm
  module Steps
    class CostSummaryController < Nsm::Steps::BaseController
      def show
        @report = Nsm::CostSummary::Report.new(current_application)
        @vat_registered = current_application.firm_office.vat_registered == YesNoAnswer::YES.to_s
      end
    end
  end
end
