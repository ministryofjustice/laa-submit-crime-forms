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
           status: 'submitted',
           updated_at: 1.day.ago,
           defendants: [build(:defendant, :valid_nsm, first_name: 'Burt', last_name: 'Bacharach')])

    create(:claim, :with_named_defendant, ufn: '120423/002', laa_reference: 'LAA-BBBBB',
           status: 'submitted', updated_at: 2.days.ago)

    create(:claim, :with_named_defendant, ufn: '120423/003', laa_reference: 'LAA-CCCC1',
           status: 'granted', updated_at: 3.days.ago)

    create(:claim, :with_named_defendant, ufn: '120423/004', laa_reference: 'LAA-CCCC2',
           status: 'further_info', updated_at: 3.days.ago)

    create(:claim, :with_named_defendant, ufn: '120423/005', laa_reference: 'LAA-CCCC3',
           status: 'part_grant', updated_at: 3.days.ago)

    create(:claim, :with_named_defendant, ufn: '120423/006', laa_reference: 'LAA-CCCC4',
           status: 'rejected', updated_at: 3.days.ago)

    create(:claim,
           :with_named_defendant,
           ufn: '120423/007',
           laa_reference: 'LAA-CCCC5',
           office_code: '9A123B',
           status: 'provider_requested',
           updated_at: 3.days.ago)

    create(:claim,
           ufn: '120423/008',
           laa_reference: 'LAA-DDDDD',
           defendants: [build(:defendant, :valid_nsm, first_name: 'Zoe', last_name: 'Zeigler')],
           status: 'draft',
           updated_at: 4.days.ago)

    create(:claim,
           ufn: '111111/111',
           laa_reference: 'LAA-EEEEE',
           status: 'draft',
           office_code: 'OTHER',
           submitter: create(:provider, :other))

    visit nsm_applications_path
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
      expect(page).to have_content('120423/008')
    end
  end

  it 'allows sorting by Defendant' do
    click_on 'Defendant'
    within top_row_selector do
      expect(page).to have_content('Burt Bacharach')
    end

    click_on 'Defendant'
    within top_row_selector do
      expect(page).to have_content('Zoe Zeigler')
    end
  end

  it 'allows sorting by Account (i.e. Office code)' do
    click_on 'Account'
    within top_row_selector do
      expect(page).to have_content('1A123B')
    end

    click_on 'Account'
    within top_row_selector do
      expect(page).to have_content('9A123B')
    end
  end

  it 'allows sorting by LAA reference' do
    click_on 'LAA reference'
    within top_row_selector do
      expect(page).to have_content('AAAAA')
    end

    click_on 'LAA reference'
    within top_row_selector do
      expect(page).to have_content('DDDDD')
    end
  end

  it 'allows sorting by Status' do
    click_on 'Status'
    within top_row_selector do
      expect(page).to have_content('Draft')
    end

    click_on 'Status'
    within top_row_selector do
      expect(page).to have_content('Submitted')
    end
  end

  def top_row_selector
    '.govuk-table tbody tr:nth-child(1)'
  end
end
