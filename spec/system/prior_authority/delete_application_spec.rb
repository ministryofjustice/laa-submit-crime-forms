require 'system_helper'

RSpec.describe 'Prior authority application deletion' do
  before do
    fill_in_until_step(:your_application_progress)
    click_on 'Back to your applications'
  end

  it 'allows the user to delete an application' do
    click_on 'Delete'
    expect(page).to have_content 'Are you sure you want to delete this draft application?'
    click_on 'Yes, delete it'
    expect(page).to have_no_content '111111/123'
  end

  it 'allows the user to cancel deleting an application' do
    click_on 'Delete'
    expect(page).to have_content 'Are you sure you want to delete this draft application?'
    click_on 'No, do not delete it'
    expect(page).to have_content '111111/123'
  end
end
