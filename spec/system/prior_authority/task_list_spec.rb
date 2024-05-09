require 'system_helper'

RSpec.describe 'Prior authority applications - task list' do
  before do
    fill_in_until_step(:primary_quote, prison_law: 'Yes')
  end

  it 'allows me to go back to a previous step without invalidating subsequent steps' do
    expect(page).to have_content 'Client details Completed'
    expect(page).to have_content 'Case and hearing details Completed'
    click_on 'Client details'
    fill_in_client_detail
    expect(page).to have_content 'Client details Completed'
    expect(page).to have_content 'Case and hearing details Completed'
  end
end
