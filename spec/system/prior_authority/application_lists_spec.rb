require 'system_helper'

RSpec.describe 'Prior authority application lists', :stub_oauth_token do
  let(:chosen_id) { SecureRandom.uuid }
  let(:submitted_id) { SecureRandom.uuid }
  let(:granted_id) { SecureRandom.uuid }
  let(:sent_back_id) { SecureRandom.uuid }
  let(:part_grant_id) { SecureRandom.uuid }
  let(:rejected_id) { SecureRandom.uuid }
  let(:auto_grant_id) { SecureRandom.uuid }

  let(:laa_references) do
    [
      { id: chosen_id, laa_reference: 'LAA-AAAAA' },
      { id: submitted_id, laa_reference: 'LAA-BBBBB' },
      { id: granted_id, laa_reference: 'LAA-CCCC1' },
      { id: sent_back_id, laa_reference: 'LAA-CCCC2' },
      { id: part_grant_id, laa_reference: 'LAA-CCCC3' },
      { id: rejected_id, laa_reference: 'LAA-CCCC4' },
      { id: auto_grant_id, laa_reference: 'LAA-CCCC5' }
    ]
  end

  let(:chosen) do
    create(:prior_authority_application,
           :full,
           id: chosen_id,
           ufn: '120423/818',
           state: 'submitted',
           updated_at: 1.day.ago)
  end

  before do
    visit provider_entra_id_omniauth_callback_path
    chosen
    submitted = create(:prior_authority_application, :full,
                       id: submitted_id,
                       state: 'submitted',
                       updated_at: 2.days.ago)
    granted = create(:prior_authority_application, :full,
                     id: granted_id,
                     state: 'granted',
                     updated_at: 3.days.ago)
    sent_back = create(:prior_authority_application, :full,
                       id: sent_back_id,
                       state: 'sent_back',
                       updated_at: 3.days.ago)
    part_grant = create(:prior_authority_application, :full,
                        id: part_grant_id,
                        state: 'part_grant',
                        updated_at: 3.days.ago)
    rejected = create(:prior_authority_application, :full,
                      id: rejected_id,
                      state: 'rejected',
                      updated_at: 3.days.ago)
    auto_grant = create(:prior_authority_application, :full,
                        id: auto_grant_id,
                        state: 'auto_grant',
                        updated_at: 3.days.ago)
    create(:prior_authority_application, ufn: '01012025/001', state: 'draft', updated_at: 4.days.ago)
    create(:prior_authority_application, ufn: '02022025/002', state: 'draft',
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
                        raw_data: ordered.map do |app|
                          attach_ref_to_payload(app)
                        end
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
          attach_ref_to_payload(app)
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

      expect(page).to have_content '01012025/001'
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
    expect(page).to have_no_content '02022025/002'
  end

  it 'links through to a readonly summary page for submitted applications' do
    visit submitted_prior_authority_applications_path

    expect(find('a', text: chosen.ufn)[:href]).to eq prior_authority_application_path(chosen)
  end

  def attach_ref_to_payload(app)
    # TODO: this method is only needed because we are
    # equating an app store payload with a local record
    # it should be considered tech debt that we aim to get rid of
    # when unifying submissions into one db
    payload = SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application: app).payload
    ref = laa_references.select { _1[:id] == payload[:application_id] }.first[:laa_reference]
    payload[:application][:laa_reference] = ref
    payload
  end
end
