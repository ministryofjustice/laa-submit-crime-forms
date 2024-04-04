require 'system_helper'

RSpec.describe 'Prior authority applications, sent back for further info - check your answers' do
  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_steps_check_answers_path(application)
  end

  let(:application) do
    create(
      :prior_authority_application,
      :full,
      status: 'sent_back',
      resubmission_deadline: 14.days.from_now,
      resubmission_requested: DateTime.current,
      further_informations: [
        build(
          :further_information,
          information_requested: 'We need further evidence for travel',
          information_supplied: 'Have attached that, thanks',
          supporting_documents: [
            build(:supporting_document, file_name: 'further_info1.pdf'),
            build(:supporting_document, file_name: 'further_info2.pdf'),
          ]
        )
      ]
    )
  end

  it 'shows the further information card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Further information requested') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: /LAA request.*We need further evidence for travel/)
        .and have_css('.govuk-summary-card__content', text: /Further information provided.*Have attached that, thanks/)
        .and have_css('.govuk-summary-card__content', text: 'Supporting documentsfurther_info1.pdffurther_info2.pdf')

      click_on 'Change'
      expect(page).to have_title('Further information requested')
    end

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end
end
