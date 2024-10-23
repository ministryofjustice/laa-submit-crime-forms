require 'rails_helper'

RSpec.describe 'User can fill in solicitor declaration', type: :system do
  let(:claim) do
    create(:claim,
           :complete,
           :case_type_breach,
           :with_full_navigation_stack,
           state: :draft,
           work_items: [work_item],
           disbursements: [build(:disbursement, :valid)])
  end

  let(:work_item) { build(:work_item, :waiting) }

  before do
    allow(SubmitToAppStore).to receive(:perform_later)
    visit provider_saml_omniauth_callback_path
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

    expect(SubmitToAppStore).to have_received(:perform_later)
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
end
