require 'system_helper'

RSpec.describe 'NSM claims lists', :stub_oauth_token do
  before do
    visit provider_entra_id_omniauth_callback_path

    # Add office code to test provider to test account number sorting
    Provider.first.tap do |provider|
      provider.update!(office_codes: %w[1A123B 9A123B])
    end

    first_submitted = create(:claim, :complete, :case_type_magistrates, :with_named_defendant,
                             ufn: '120423/002', laa_reference: 'LAA-BBBBB', state: 'submitted',
                             updated_at: 2.days.ago)

    second_submitted = create(:claim, :complete, :case_type_breach,
                              laa_reference: 'LAA-AAAAA', ufn: '120423/001', state: 'submitted', updated_at: 1.day.ago,
                              defendants: [build(:defendant, :valid_nsm, first_name: 'Burt', last_name: 'Bacharach')])

    stub_request(:post, 'https://app-store.example.com/v1/submissions/searches').with(
      body:  {
        'sort_by' => nil,
        'per_page' => 10,
        'application_type' => 'crm7',
        'account_number' => %w[1A123B 9A123B],
        'status_with_assignment' => %w[in_progress not_assigned provider_updated]
      }.to_json
    ).to_return(
      status: 201,
      body: {
        metadata: { total_results: 2 },
        raw_data: [
          SubmitToAppStore::NsmPayloadBuilder.new(claim: second_submitted).payload,
          SubmitToAppStore::NsmPayloadBuilder.new(claim: first_submitted).payload,
        ]
      }.to_json
    )

    granted = create(:claim, :complete, :case_type_magistrates, ufn: '120423/003', laa_reference: 'LAA-CCCC1',
           state: 'granted', updated_at: 3.days.ago,
           defendants: [build(:defendant, :valid_nsm, first_name: 'Burt', last_name: 'Bacharach')])

    sent_back = create(:claim, :complete, :case_type_magistrates, :with_named_defendant, ufn: '120423/004',
           state: 'sent_back', updated_at: 3.days.ago, laa_reference: 'LAA-CCCC2')

    part_grant = create(:claim, :complete, :case_type_magistrates, :with_named_defendant, ufn: '120423/005',
           state: 'part_grant', updated_at: 3.days.ago, laa_reference: 'LAA-CCCC3')

    rejected = create(:claim, :complete, :case_type_magistrates, :with_named_defendant, ufn: '120423/006',
           state: 'rejected', updated_at: 3.days.ago, laa_reference: 'LAA-CCCC4')

    stub_request(:post, 'https://app-store.example.com/v1/submissions/searches').with do |request|
      JSON.parse(request.body)['status_with_assignment'] == %w[granted part_grant rejected auto_grant sent_back expired]
    end.to_return(lambda do |request|
                    data = JSON.parse(request.body)
                    claims = [granted, sent_back, part_grant, rejected]
                    ordered = case data['sort_by']
                              when 'ufn', 'client_name', 'laa_reference'
                                data['sort_direction'] == 'descending' ? claims.reverse : claims
                              when 'status_with_assignment'
                                data['sort_direction'] == 'descending' ? [sent_back] : [granted]
                              else
                                claims.reverse
                              end
                    {
                      status: 201,
                      body: {
                        metadata: { total_results: 4 },
                        raw_data: ordered.map do |claim|
                          SubmitToAppStore::NsmPayloadBuilder.new(claim:).payload.merge(application_state: claim.state)
                        end
                      }.to_json
                    }
                  end)

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
    visit reviewed_nsm_applications_path
    click_on 'UFN'
    within top_row_selector do
      expect(page).to have_content('120423/003')
    end

    click_on 'UFN'
    within top_row_selector do
      expect(page).to have_content('120423/006')
    end
  end

  it 'allows sorting by Defendant' do
    visit reviewed_nsm_applications_path
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
    visit reviewed_nsm_applications_path
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
    visit reviewed_nsm_applications_path
    click_on 'LAA reference'
    within top_row_selector do
      expect(page).to have_content('CCCC1')
    end

    click_on 'LAA reference'
    within top_row_selector do
      expect(page).to have_content('CCCC4')
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
