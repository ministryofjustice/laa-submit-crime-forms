class OfficeCodeService
  class << self
    def call(username)
      office_details = ProviderDataApiClient.user_office_details(username)
      if FeatureFlags.provider_api_v1.enabled?
        office_details.map { _1['officeCodes'].pluck('firmOfficeCode') }.flatten
      else
        office_details.pluck('firmOfficeCode')
      end
    end
  end
end
