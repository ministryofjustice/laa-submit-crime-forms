class SubmitToAppStore
  class PayloadBuilder
    def self.call(submission, include_events: true)
      case submission
      when Claim
        NsmPayloadBuilder.new(claim: submission).payload
      when PriorAuthorityApplication
        PriorAuthorityPayloadBuilder.new(application: submission, include_events: include_events).payload
      else
        raise 'Unknown submission type'
      end
    end
  end
end
