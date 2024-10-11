class OfficeCodeService
  class << self
    def call(email)
      user_details = ProviderDataApiClient.user_details(email)
      office_details = ProviderDataApiClient.user_office_details(user_details['userLogin'])
      office_details.pluck('firmOfficeCode')
    end
  end
end
