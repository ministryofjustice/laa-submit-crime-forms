require 'system_helper'

RSpec.describe 'NSM claims lists' do
  before do
    visit provider_saml_omniauth_callback_path

    # Add office code to test provider to test account number sorting
    Provider.find_by(uid: 'test-user').tap do |provider|
      provider.update!(office_codes: %w[1A123B 9A123B])
    end

    create(:claim,
           :complete,
           laa_reference: 'LAA-AAAAA',
           ufn: '120423/001',
           state: 'submitted',
           updated_at: 1.day.ago,
           defendants: [build(:defendant, :valid_nsm, first_name: 'Burt', last_name: 'Bacharach')])

    create(:claim, :with_named_defendant, ufn: '120423/002', laa_reference: 'LAA-BBBBB',
           state: 'submitted', updated_at: 2.days.ago)

    create(:claim, :with_named_defendant, ufn: '120423/003', laa_reference: 'LAA-CCCC1',
           state: 'granted', updated_at: 3.days.ago)

    create(:claim, :with_named_defendant, ufn: '120423/004', laa_reference: 'LAA-CCCC2',
           state: 'sent_back', updated_at: 3.days.ago)

    create(:claim, :with_named_defendant, ufn: '120423/005', laa_reference: 'LAA-CCCC3',
           state: 'part_grant', updated_at: 3.days.ago)

    create(:claim, :with_named_defendant, ufn: '120423/006', laa_reference: 'LAA-CCCC4',
           state: 'rejected', updated_at: 3.days.ago)

    create(:claim,
           ufn: '120423/008',
           laa_reference: 'LAA-DDDDD',
           defendants: [build(:defendant, :valid_nsm, first_name: 'Zoe', last_name: 'Zeigler')],
           state: 'draft',
           updated_at: 4.days.ago)

    create(:claim,
           ufn: '111111/111',
           laa_reference: 'LAA-EEEEE',
           state: 'draft',
           office_code: 'OTHER',
           submitter: create(:provider, :other))

    visit submitted_nsm_applications_path
  end

  it 'only shows reviewed claims on reviewed tab' do
    visit reviewed_nsm_applications_path

    expect(page).to have_content(%r{120423/006.*120423/005.*120423/004.*120423/003}m)
    expect(page).to have_content('Showing 4 of 4 claims')
  end

  it 'only shows submitted claims on submitted tab' do
    visit submitted_nsm_applications_path

    expect(page).to have_content(%r{120423/001.*120423/002}m)
    expect(page).to have_content('Showing 2 of 2 claims')
  end

  it 'only shows draft claims on draft tab' do
    visit draft_nsm_applications_path

    expect(page).to have_content('120423/008')
    expect(page).to have_content('Showing 1 of 1 claims')
  end

  it 'shows most recently updated at the top by default' do
    within top_row_selector do
      expect(page).to have_content(1.day.ago.to_fs(:stamp))
    end
  end

  it 'does not show applications from other offices' do
    expect(page).to have_no_content 'EEEEE'
  end

  it 'allows sorting by UFN' do
    click_on 'UFN'
    within top_row_selector do
      expect(page).to have_content('120423/001')
    end

    click_on 'UFN'
    within top_row_selector do
      expect(page).to have_content('120423/002')
    end
  end

  it 'allows sorting by Defendant' do
    click_on 'Defendant'
    within top_row_selector do
      expect(page).to have_content('Burt Bacharach')
    end

    click_on 'Defendant'
    within top_row_selector do
      expect(page).to have_content('Jim Bob')
    end
  end

  it 'allows sorting by Account (i.e. Office code)' do
    click_on 'Account'
    within top_row_selector do
      expect(page).to have_content('1A123B')
    end

    click_on 'Account'
    within top_row_selector do
      expect(page).to have_content('1A123B')
    end
  end

  it 'allows sorting by LAA reference' do
    click_on 'LAA reference'
    within top_row_selector do
      expect(page).to have_content('AAAAA')
    end

    click_on 'LAA reference'
    within top_row_selector do
      expect(page).to have_content('BBBBB')
    end
  end

  it 'allows sorting by Status in "Reviewed"' do
    visit nsm_applications_path

    click_on 'Status'
    within top_row_selector do
      expect(page).to have_content('Granted')
    end

    click_on 'Status'
    within top_row_selector do
      expect(page).to have_content('Update needed')
    end
  end

  def top_row_selector
    '.govuk-table tbody tr:nth-child(1)'
  end
end
