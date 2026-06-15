class SubmitToAppStore
  class PayloadBuilder
    def self.call(submission, current_date: nil)
      payload = {}
      case submission
      when Claim, AppStore::V1::Nsm::Claim
        payload = NsmPayloadBuilder.new(claim: submission).payload
      when PriorAuthorityApplication
        payload = PriorAuthorityPayloadBuilder.new(application: submission).payload
      else
        raise 'Unknown submission type'
      end
      payload[:current_date] = current_date unless current_date.blank? || HostEnv.production?
      payload
    end
  end
end
