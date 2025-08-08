require 'system_helper'

RSpec.describe 'NSM application deletion' do
  before do
    visit provider_entra_id_omniauth_callback_path

    create(:claim,
           ufn: '120423/008',
           defendants: [build(:defendant, :valid_nsm, first_name: 'Zoe', last_name: 'Zeigler')],
           state: 'draft',
           updated_at: 4.days.ago)
    visit draft_nsm_applications_path
  end

  it 'allows the user to delete an application' do
    click_on 'Delete'
    expect(page).to have_content 'Are you sure you want to delete this draft claim?'
    click_on 'Yes, delete it'
    expect(page).to have_no_content '120423/008'
  end

  it 'allows the user to cancel deleting an application' do
    click_on 'Delete'
    expect(page).to have_content 'Are you sure you want to delete this draft claim?'
    click_on 'No, do not delete it'
    expect(page).to have_content '120423/008'
  end
end
