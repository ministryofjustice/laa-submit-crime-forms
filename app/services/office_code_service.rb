class OfficeCodeService
  class << self
    def call(username)
      office_details = ProviderDataApiClient.user_office_details(username)
      office_details.pluck('firmOfficeCode')
    end
  end
end
