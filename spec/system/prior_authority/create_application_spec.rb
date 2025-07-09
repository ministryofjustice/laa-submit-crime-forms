require 'system_helper'

RSpec.describe 'Prior authority application creation', :stub_app_store_search, :stub_oauth_token do
  before do
    visit provider_entra_id_omniauth_callback_path
    visit prior_authority_applications_path
  end

  it 'allows the user to create an application' do
    click_on 'Make a new application'

    expect(page).to have_content 'Is this a Prison Law matter?'
    choose 'Yes'
    click_on 'Save and continue'

    expect(page).to have_content 'Are you applying for a total authority of less than £500?'
    choose 'No'
    click_on 'Save and continue'

    fill_in 'What is your unique file number (UFN)?', with: '070324/123'
    click_on 'Save and continue'

    expect(page).to have_content 'Your application progress'
    click_on 'Back to your applications'
    click_on 'Drafts'
    expect(page).to have_content '070324/123'
  end

  it 'performs validations' do
    click_on 'Make a new application'

    click_on 'Save and continue'
    expect(page).to have_content 'Select yes if this is a Prison Law matter'
    choose 'Yes'
    click_on 'Save and continue'

    click_on 'Save and continue'
    expect(page).to have_content 'Select yes if you are applying for a total authority of less than £500'
    choose 'No'
    click_on 'Save and continue'

    click_on 'Save and continue'
    expect(page).to have_content 'Enter the unique file number'
  end

  it 'offboards the user for authority request of less than £500' do
    click_on 'Make a new application'

    choose 'Yes'
    click_on 'Save and continue'

    expect(page).to have_content 'Are you applying for a total authority of less than £500?'
    choose 'Yes'
    click_on 'Save and continue'
    expect(page).to have_title 'You do not need to apply'
    expect(page)
      .to have_content 'to incur disbursements for a Prison Law matter if the total authority is less than £500.'
  end

  it 'offboards the user for authority request of less than £100' do
    click_on 'Make a new application'

    choose 'No'
    click_on 'Save and continue'

    expect(page).to have_content 'Are you applying for a total authority of less than £100?'
    choose 'Yes'
    click_on 'Save and continue'
    expect(page).to have_title 'You do not need to apply'
    expect(page)
      .to have_content 'to incur disbursements if the total authority is less than £100.'
  end

  context 'when I have a single office code' do
    before do
      Provider.first.update(office_codes: %w[1A123B])
    end

    it 'stores my office code against the application' do
      click_on 'Make a new application'
      expect(PriorAuthorityApplication.first.office_code).to eq '1A123B'
    end
  end

  context 'when I have multiple office codes' do
    before do
      Provider.first.update(office_codes: %w[1A123B 1K022G])
    end

    it 'leaves the office code blank for now' do
      click_on 'Make a new application'
      expect(PriorAuthorityApplication.first.office_code).to be_nil
    end
  end

  context 'when I clone an application' do
    let(:claim) { create(:prior_authority_application, :with_all_tasks_completed, :as_draft) }
    # Ignore fields that `dup` doesn't handle, as well as fields that won't get duplicated
    # We also have to ignore `viewed_steps` as we redirect to the start page after cloning
    let(:ignored_attrs) { %w[id created_at updated_at core_search_fields laa_reference viewed_steps] }

    before do
      claim.save
      visit drafts_prior_authority_applications_path
    end

    it 'can see clone button' do
      expect(page).to have_content(I18n.t('.prior_authority.applications.tabs.clone'))
    end

    it 'can clone an application' do
      expect(PriorAuthorityApplication.count).to eq(1)
      click_on 'Clone'
      expect(page).to have_content(I18n.t('.prior_authority.applications.clone.cloned'))
      expect(PriorAuthorityApplication.count).to eq(2)

      expected = PriorAuthorityApplication.first.attributes.except(*ignored_attrs)
      actual = PriorAuthorityApplication.second.attributes.except(*ignored_attrs)

      expect(expected).to eq(actual)
    end

    context 'with missing entities' do
      let(:claim) { create(:prior_authority_application, :as_draft) }

      it 'does not try and duplicate them' do
        expect(PriorAuthorityApplication.count).to eq(1)
        click_on 'Clone'
        expect(page).to have_content(I18n.t('.prior_authority.applications.clone.cloned'))
        expect(PriorAuthorityApplication.count).to eq(2)

        expected = PriorAuthorityApplication.first.attributes.except(*ignored_attrs)
        actual = PriorAuthorityApplication.second.attributes.except(*ignored_attrs)

        expect(expected).to eq(actual)
      end
    end

    context 'when the app is in production' do
      before do
        allow(HostEnv).to receive(:env_name).and_return('production')
        Rails.application.reload_routes!
      end

      it 'returns a 404' do
        get clone_prior_authority_application_path(PriorAuthorityApplication.first.id)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
