require 'system_helper'

RSpec.describe 'Prior authority applications - add service costs', :javascript, type: :system do
  before do
    fill_in_until_step(:primary_quote_summary)
  end

  it 'shows a summary screen' do
    expect(page).to have_content 'Primary quote summary'
    expect(page).to have_content 'Quote total cost £6.15'
  end

  it 'is the default screen if I return to the primary quote section' do
    click_on 'Save and come back later'
    click_on 'Primary quote'
    expect(page).to have_content 'Primary quote summary'
  end
end
