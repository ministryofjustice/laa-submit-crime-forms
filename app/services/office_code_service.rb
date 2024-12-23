class OfficeCodeService
  class << self
    def call(username, api_version = nil)
      office_details = ProviderDataApiClient.user_office_details(username, api_version)
      if api_version == 1
        office_details.map { _1['officeCodes'].pluck('firmOfficeCode') }.flatten
      else
        office_details.pluck('firmOfficeCode')
      end
    end
  end
end
