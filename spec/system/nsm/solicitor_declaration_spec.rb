require 'rails_helper'

RSpec.describe 'User can fill in solicitor declaration', :stub_oauth_token, type: :system do
  let(:claim) do
    create(:claim,
           :complete,
           :case_type_breach,
           state: :draft,
           work_items: [work_item],
           disbursements: [build(:disbursement, :valid)])
  end

  let(:work_item) { build(:work_item, :waiting) }

  before do
    stub_app_store_payload(claim, status: :submitted)
    visit provider_entra_id_omniauth_callback_path
  end

  context 'when submission succeeds' do
    let(:job) { instance_double(SubmitToAppStore, perform: true) }

    before do
      allow(SubmitToAppStore).to receive(:new).and_return(job)
    end

    it 'can do green path' do
      visit edit_nsm_steps_solicitor_declaration_path(claim.id)

      fill_in 'Full name',
              with: 'John Doe'
      click_on 'Save and submit'
      expect(claim.reload).to have_attributes(
        signatory_name: 'John Doe',
        state: 'submitted'
      )

      expect(job).to have_received(:perform)
    end

    it 'persists work item positions' do
      visit edit_nsm_steps_solicitor_declaration_path(claim.id)

      fill_in 'Full name',
              with: 'John Doe'

      expect { click_on 'Save and submit' }
        .to change { claim.work_items.where.not(position: nil).count }
        .from(0)
        .to(1)
    end

    it 'persists disbursement positions' do
      visit edit_nsm_steps_solicitor_declaration_path(claim.id)

      fill_in 'Full name',
              with: 'John Doe'

      expect { click_on 'Save and submit' }
        .to change { claim.disbursements.where.not(position: nil).count }
        .from(0)
        .to(1)
    end
  end

  context 'when claim is not complete at the point of submission' do
    it 'redirects me' do
      visit edit_nsm_steps_solicitor_declaration_path(claim.id)
      work_item.update(work_type: nil)
      fill_in 'Full name', with: 'John Doe'
      click_on 'Save and submit'
      expect(claim.reload).to be_draft
      expect(page).to have_current_path nsm_steps_start_page_path(claim.id)
    end
  end

  context 'when the app store fails', :stub_oauth_token do
    before do
      stub_request(:post, 'https://app-store.example.com/v1/application/').to_return(status: 500)
    end

    it 'errors out without updating state' do
      visit edit_nsm_steps_solicitor_declaration_path(claim.id)

      fill_in 'Full name',
              with: 'John Doe'
      expect { click_on 'Save and submit' }.to raise_error "Unexpected response from AppStore - status 500 for '#{claim.id}'"

      expect(claim.reload).to have_attributes(
        state: 'draft'
      )
    end
  end
end
