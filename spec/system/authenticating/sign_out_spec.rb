require 'rails_helper'

RSpec.describe 'Sign out' do
  let(:user) { create(:caseworker) }

  before do
    sign_in user
    visit '/assess'
    click_link('Sign out')
  end

  it 'signs the user out' do
    expect(page).not_to have_content 'Your list'
  end

  it 'shows the notification banner' do
    expect(page).to have_content('You have signed out')
  end
end
