require 'rails_helper'

RSpec.describe 'User can see cost breakdowns', type: :system do
  let(:claim) { create(:claim, :costed, work_types:) }
  let(:work_types) do
    [
      [WorkTypes::ATTENDANCE_WITHOUT_COUNSEL.to_s, 90],
      [WorkTypes::ADVOCACY.to_s, 104],
      [WorkTypes::ADVOCACY.to_s, 86],
    ]
  end

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit steps_cost_summary_path(claim.id)

    doc = Nokogiri::HTML(page.html)
    values = doc.css('.govuk-summary-card h2, dd, dt').map(&:text)

    expect(values).to eq(
      [
        'Work items total £260.68',
        'Items', 'Total per item',
        'Attendance without counsel', '£53.52', # 35.68 * 90 / 60
        'Preparation', '£0.00',
        'Advocacy', '£207.16', # 65.42 * (104 + 86) / 60
        'Total', '£260.68',

        'Letters and phone calls total £20.45',
        'Items', 'Total per item',
        'Letters', '£8.18', # 4.09 * 2
        'Phone calls', '£12.27', # 4.09 * 3
        'Total', '£20.45',

        'Disbursements total £0.00',
        'Items', 'Total per item',
        'Total', '£0.00'
      ]
    )
  end
end
