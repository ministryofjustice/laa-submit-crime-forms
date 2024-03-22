module PriorAuthority
  module Steps
    class FurtherInformationController < BaseController
      def edit
        @explanation = current_application.further_information_explanation
      end

      def update

      end

      private

      def as
        :further_information
      end
    end
  end
end
