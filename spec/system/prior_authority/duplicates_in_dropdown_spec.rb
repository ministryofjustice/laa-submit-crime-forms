# This test is to ensure no regressions related to duplicates
# occuring in the suggestion dropdown when editing
require 'rails_helper'

RSpec.describe 'Ensure no duplicates in list' do
  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'for primary quote service_type' do
    submission = create(
      :prior_authority_application, :with_primary_quote,
      service_type: 'meteorologist',
      quotes: [build(:quote, :primary_per_item)]
    )

    visit edit_prior_authority_steps_primary_quote_path(submission)

    options = page.all('select#prior-authority-steps-primary-quote-form-service-type-autocomplete-field option')
                  .map(&:value)
    matching_options = options.select { _1.downcase == submission.service_type.downcase }

    expect(matching_options).to eq(['meteorologist'])
  end
end
