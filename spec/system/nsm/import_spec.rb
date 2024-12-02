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
      'We imported 1 work item and 2 disbursements. ' \
      'You will need to enter all other details manually, and check carefully the imported details.'
    )
    expect(WorkItem.first).to have_attributes(
      work_type: 'travel',
      time_spent: 300,
      completed_on: Date.new(2013, 1, 21),
      fee_earner: 'RT',
      uplift: 100,
      position: 1,
    )
    expect(Disbursement.find_by(miles: nil)).to have_attributes(
      disbursement_type: 'other',
      other_type: 'DNA Testing',
      total_cost_without_vat: 400.0,
      details: 'These are details of DNA testing.',
      apply_vat: 'true',
      vat_amount: 80.0,
    )
    expect(Disbursement.find_by(disbursement_type: 'car')).to have_attributes(
      miles: 12.0,
      details: 'Mileage',
      apply_vat: 'false',
      vat_amount: nil,
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
    expect(page).to have_content(
      'We were unable to read any work items or disbursements from this file. ' \
      'Please try a different file or enter your details manually.'
    )
  end
end
