class OfficeCodeService
  class << self
    def call(username)
      office_details = ProviderDataApiClient.user_office_details(username)

      office_details.map { _1['officeCodes'].pluck('firmOfficeCode') }.flatten
    end
  end
end
