require 'system_helper'

RSpec.describe 'Import claims' do
  before do
    visit provider_saml_omniauth_callback_path
    visit new_nsm_import_path
  end

  it 'lets me import a claim' do
    attach_file(file_fixture('import_sample.xml'))
    click_on 'Save and continue'
    expect(page).to have_content(
      'We imported 3 work items and 2 disbursements. ' \
      'You will need to enter all other details manually, and check carefully the imported details.'
    )
    expect(WorkItem.find_by(position: 1)).to have_attributes(
      work_type: 'preparation',
      time_spent: 120,
      completed_on: Date.new(2024, 1, 15),
      fee_earner: 'JS',
      uplift: 20,
      position: 1,
    )
    expect(Disbursement.find_by(miles: nil)).to have_attributes(
      disbursement_type: 'other',
      other_type: 'psychiatric_reports',
      total_cost_without_vat: 350.00,
      details: 'Expert psychiatric assessment',
      apply_vat: 'true',
      vat_amount: 70.00,
    )
    expect(Disbursement.find_by(disbursement_type: 'car')).to have_attributes(
      miles: 45.5,
      details: 'Travel to Liverpool Magistrates Court',
      apply_vat: 'true',
      vat_amount: 4.09,
    )
  end

  it 'validates file type' do
    attach_file(file_fixture('test.json'))
    click_on 'Save and continue'
    expect(page).to have_content "The file must be of type 'XML'"
  end

  it 'handles unreadable files' do
    attach_file(file_fixture('unreadable_import.xml'))
    click_on 'Save and continue'
    expect(page).to have_content("ERROR: Element 'claim': Missing child element(s).")
  end
end
