module Nsm
  module Steps
    class CheckAnswersController < Nsm::Steps::BaseController
      def show
        @report = CheckAnswers::Report.new(current_application)
      end
    end
  end
end
