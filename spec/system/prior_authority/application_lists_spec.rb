require 'system_helper'

RSpec.describe 'Prior authority application lists', :stub_oauth_token do
  let(:chosen) do
    create(:prior_authority_application,
           :full,
           laa_reference: 'LAA-AAAAA',
           ufn: '120423/818',
           state: 'submitted',
           updated_at: 1.day.ago)
  end

  before do
    visit provider_entra_id_omniauth_callback_path
    chosen
    submitted = create(:prior_authority_application, :full, laa_reference: 'LAA-BBBBB', state: 'submitted',
                        updated_at: 2.days.ago)
    granted = create(:prior_authority_application, :full, laa_reference: 'LAA-CCCC1', state: 'granted',
                        updated_at: 3.days.ago)
    sent_back = create(:prior_authority_application, :full, laa_reference: 'LAA-CCCC2', state: 'sent_back',
                        updated_at: 3.days.ago)
    part_grant = create(:prior_authority_application, :full, laa_reference: 'LAA-CCCC3', state: 'part_grant',
                        updated_at: 3.days.ago)
    rejected = create(:prior_authority_application, :full, laa_reference: 'LAA-CCCC4', state: 'rejected',
                        updated_at: 3.days.ago)
    auto_grant = create(:prior_authority_application, :full, laa_reference: 'LAA-CCCC5', state: 'auto_grant',
                        updated_at: 3.days.ago)
    create(:prior_authority_application, laa_reference: 'LAA-DDDDD', state: 'draft', updated_at: 4.days.ago)
    create(:prior_authority_application, laa_reference: 'LAA-EEEEE', state: 'draft',
           office_code: 'OTHER', provider: create(:provider, :other))

    stub_request(:post, 'https://app-store.example.com/v1/submissions/searches').with do |request|
      JSON.parse(request.body)['status_with_assignment'] == %w[in_progress not_assigned provider_updated]
    end.to_return(lambda do |request|
                    data = JSON.parse(request.body)
                    applications = [chosen, submitted]
                    ordered = case data['sort_direction']
                              when 'descending'
                                applications.reverse
                              else
                                applications
                              end
                    {
                      status: 201,
                      body: {
                        metadata: { total_results: 4 },
                        raw_data: ordered.map { SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application: _1).payload }
                      }.to_json
                    }
                  end)

    stub_request(:post, 'https://app-store.example.com/v1/submissions/searches').with do |request|
      JSON.parse(request.body)['status_with_assignment'] == %w[granted part_grant rejected auto_grant sent_back expired]
    end.to_return(
      status: 201,
      body: {
        metadata: { total_results: 4 },
        raw_data: [granted, sent_back, part_grant, rejected, auto_grant].map do |app|
          SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application: app).payload
        end
      }.to_json
    )
  end

  describe 'only shows right applications in the right tabs' do
    it 'for submitted applications' do
      visit submitted_prior_authority_applications_path

      expect(page).to have_content 'AAAAA'
      expect(page).to have_content 'BBBBB'
    end

    it 'for reviewed applications' do
      visit reviewed_prior_authority_applications_path

      expect(page)
        .to have_content('CCCC1')
        .and have_content('CCCC2')
        .and have_content('CCCC3')
        .and have_content('CCCC4')
        .and have_content('CCCC5')
    end

    it 'for draft applications' do
      visit drafts_prior_authority_applications_path

      expect(page).to have_content 'DDDDD'
    end
  end

  it 'shows most recently updated at the top by default' do
    visit submitted_prior_authority_applications_path

    expect(page.body).to match(/AAAAA.*BBBBB.*/m)
  end

  it 'allows sorting by columns in ascending and descending order' do
    visit submitted_prior_authority_applications_path

    expect(page).to have_content(/AAAAA.*BBBBB.*/m)
    click_on 'LAA reference'
    click_on 'LAA reference'
    expect(page).to have_content(/BBBBB.*AAAAA.*/m)
  end

  it 'does not show applications from other offices' do
    expect(page).to have_no_content 'EEEEE'
  end

  it 'links through to a readonly summary page for submitted applications' do
    visit submitted_prior_authority_applications_path

    expect(find('a', text: chosen.ufn)[:href]).to eq prior_authority_application_path(chosen)
  end
end
