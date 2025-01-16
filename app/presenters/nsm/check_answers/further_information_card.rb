module Nsm
  module CheckAnswers
    class FurtherInformationCard < Base
      include FurtherInformationPresentable

      def initialize(further_information, claim)
        @group = 'further_information'
        @section = 'further_information'
        @further_information = further_information
        @claim = claim
        super()
      end
    end
  end
end
