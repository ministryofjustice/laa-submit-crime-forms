require 'pdf-reader'
require 'system_helper'

def import_file(file, advance_to_details: false)
  attach_file(file_fixture(file))
  # progress to defendant details form

  click_on 'Save and continue' # 'What you are claiming for'
  return unless advance_to_details

  click_on 'Save and continue' # 'Which firm office account number is this claim for?'
  click_on 'Save and continue' # 'Was this case worked on in an office in an undesignated area?'
  click_on 'Save and continue' # 'Is the first court that heard this case in an undesignated area?'
end

def check_error_pages(page_body, page, error)
  output = StringIO.new
  output.puts(page_body)
  pdf = PDF::Reader.new(output)

  expect(pdf.page(page)).to have_content(error)
end

RSpec.describe 'Import claims' do
  let(:fixed_time) { DateTime.new(2025, 4, 8, 10, 30, 0) }

  before do
    allow(DateTime).to receive(:now).and_return(fixed_time)

    visit provider_saml_omniauth_callback_path
    visit new_nsm_import_path
  end

  it 'shows error if no file selected' do
    click_on 'Save and continue'
    expect(page).to have_content(I18n.t('activemodel.errors.models.nsm/import_form.attributes.file_upload.blank'))
  end

  it 'lets me import a claim' do
    import_file('import_sample.xml')
    expect(page).to have_content('You imported 3 work items and 2 disbursements.')
    expect(page).to have_content('To submit the claim, check the uploaded claim details and update any incomplete information.')

    expect(Claim.first.import_date).to eq(fixed_time)
  end

  it 'handles a single reason_for_claim' do
    import_file('import_sample_with_one_reason.xml', advance_to_details: true)

    click_on 'Firm details'
    click_on 'Save and continue' # Firm details
    click_on 'Save and continue' # Contact details
    choose 'No'
    click_on 'Save and continue' # Defendants
    click_on 'Save and continue' # Case details
    click_on 'Save and continue' # Hearing details
    click_on 'Save and continue' # Case Disposal

    expect(all('input[type="checkbox"]').count(&:checked?)).to eq(1)
  end

  context 'defendants import' do
    before do
      import_file('import_sample_with_missing_fields.xml', advance_to_details: true)

      click_on 'Firm details' # 'Your claim progress'
      click_on 'Save and continue' # 'Firm details'
      click_on 'Save and continue' # 'Contact details'
    end

    it 'shows defendant info incomplete message and updates messageing after corrections' do
      expect(page).to have_content('2 defendants have missing or incomplete information: defendant 2, defendant 3')
      first(:link_or_button, 'defendant 2').click
      fill_in 'Last name', with: 'Genet'
      fill_in 'MAAT ID number', with: '1234567'
      click_on 'Save and continue'
      expect(page).to have_content('1 defendant has missing or incomplete information: defendant 3')
    end

    it 'shows number of included defendants after incomplete defendants are updated' do
      expect(page).to have_content('2 defendants have missing or incomplete information: defendant 2, defendant 3')
      first(:link_or_button, 'defendant 2').click
      fill_in 'Last name', with: 'Mansfield'
      fill_in 'MAAT ID number', with: '1234567'
      click_on 'Save and continue'
      first(:link_or_button, 'defendant 3').click
      fill_in 'First name', with: 'Mel'
      click_on 'Save and continue'
      expect(page).to have_content("You've added 3 defendants")
    end
  end

  it 'validates file type' do
    import_file('test.json')

    expect(page).to have_content "The file must be of type 'XML'"
  end

  it 'handles unreadable files' do
    import_file('unreadable_import.xml')

    expect(page).to have_content('The XML file must contain data in the correct format')

    click_on 'error summary (PDF)'

    output = StringIO.new
    output.puts(page.body)
    pdf = PDF::Reader.new(output)
    expect(pdf.page(1)).to have_content("2:0: ERROR: Element 'claim': Missing child element(s)")
  end

  it 'handles unmatched fields' do
    import_file('unmatched_fields.xml')

    expect(page).to have_content('The XML file must contain data in the correct format')
    click_on 'error summary (PDF)'

    check_error_pages(page.body, 1, "2:0: ERROR: Element 'claim': Missing child element(s)")
    output = StringIO.new
    output.puts(page.body)
    pdf = PDF::Reader.new(output)
    expect(pdf.page(1)).to have_content("2:0: ERROR: Element 'claim': Missing child element(s)")
  end

  it 'handles unsupported versions' do
    attach_file(file_fixture('import_sample_incorrect_version.xml'))
    click_on 'Save and continue'
    expect(page).to have_content(
      I18n.t('activemodel.errors.models.nsm/import_form.attributes.file_upload.validation_errors')
    )

    click_on 'error summary (PDF)'

    output = StringIO.new
    output.puts(page.body)
    pdf = PDF::Reader.new(output)
    expect(pdf.page(1)).to have_content('XML version 2 is not supported')
  end

  it 'handles missing version element' do
    attach_file(file_fixture('import_sample_without_version.xml'))
    click_on 'Save and continue'
    expect(page).to have_content(
      I18n.t('activemodel.errors.models.nsm/import_form.attributes.file_upload.validation_errors')
    )

    click_on 'error summary (PDF)'

    output = StringIO.new
    output.puts(page.body)
    pdf = PDF::Reader.new(output)
    expect(pdf.page(1)).to have_content(I18n.t('nsm.imports.errors.missing_version'))
  end

  it 'handles invalid version number' do
    # Create a fixture with invalid version element
    attach_file(file_fixture('import_sample_invalid_version.xml'))
    click_on 'Save and continue'
    expect(page).to have_content(
      I18n.t('activemodel.errors.models.nsm/import_form.attributes.file_upload.validation_errors')
    )

    click_on 'error summary (PDF)'

    output = StringIO.new
    output.puts(page.body)
    pdf = PDF::Reader.new(output)
    expect(pdf.page(1)).to have_content(I18n.t('nsm.imports.errors.invalid_version'))
  end
end
