require 'rails_helper'

RSpec.describe 'User can provide supporting evidence', javascript: true, type: :system do
  let(:claim) { Claim.create(office_code: 'AAAAA') }

  it 'does not show the mail address' do
    visit provider_saml_omniauth_callback_path

    visit edit_steps_supporting_evidence_path(claim.id)

    doc = Nokogiri::HTML(page.html)
    values = doc.xpath('//*[@id="steps-supporting-evidence-form-send-by-post-true-conditional"]').map do |node|
      node.attribute('class')
    end

    expect(values[0].value).to eq 'govuk-checkboxes__conditional govuk-checkboxes__conditional--hidden'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(send_by_post: false)
  end

  it 'does shows the mail address' do
    visit provider_saml_omniauth_callback_path

    visit edit_steps_supporting_evidence_path(claim.id)

    check('steps-supporting-evidence-form-send-by-post-true-field', allow_label_click: true)

    doc = Nokogiri::HTML(page.html)
    values = doc.xpath('//*[@id="steps-supporting-evidence-form-send-by-post-true-conditional"]').map do |node|
      node.attribute('class')
    end

    expect(values[0].value).to eq 'govuk-checkboxes__conditional'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(send_by_post: true)
  end
end
