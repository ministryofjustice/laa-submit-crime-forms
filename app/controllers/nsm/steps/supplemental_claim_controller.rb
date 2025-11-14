module Nsm
  module Steps
    class SupplementalClaimController < ApplicationController
      def show
        # @record_id is needed for the back button of this page
        @record_id = if params[:claim_id] == StartPage::NEW_RECORD
                       StartPage::NEW_RECORD
                     else
                       params[:claim_id]
                     end
      end
    end
  end
end
