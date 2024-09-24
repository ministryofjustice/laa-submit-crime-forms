module Nsm
  module CheckAnswers
    class FurtherInformationCard < Base
      include FurtherInformationPresentable

      def initialize(further_information)
        @group = 'further_information'
        @section = 'further_information'
        @further_information = further_information
        super()
      end
    end
  end
end
