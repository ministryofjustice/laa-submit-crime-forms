module Nsm
  module Steps
    class BaseController < ::Steps::BaseStepController
      layout 'nsm'

      private

      def service
        Providers::Gatekeeper::NSM
      end
    end
  end
end
