require 'rails_helper'

RSpec.describe 'User can see cost breakdowns', type: :system do
  let(:claim) { Claim.create(office_code:, letters:, calls:, rep_order_date:) }

  let(:office_code) { 'AAA' }
  let(:letters) { 2 }
  let(:calls) { 3 }
  let(:rep_order_date) { Date.yesterday }
  let(:work_items) do
    [
      WorkItem.new(
        work_type: WorkTypes::ATTENDANCE_WITHOUT_COUNSEL.to_s,
        time_spent: 90,
        completed_on: Date.yesterday,
        fee_earner: 'aaa',
        uplift: nil,
      ),
      WorkItem.new(
        work_type: WorkTypes::ADVOCACY.to_s,
        time_spent: 104,
        completed_on: Date.yesterday,
        fee_earner: 'aaa',
        uplift: nil,
      ),
      WorkItem.new(
        work_type: WorkTypes::ADVOCACY.to_s,
        time_spent: 86,
        completed_on: Date.yesterday,
        fee_earner: 'aaa',
        uplift: nil,
      ),
    ]
  end

  before do
    work_items.each do |work_item|
      claim.work_items << work_item
    end

    claim.update(navigation_stack: ["/applications/#{claim.id}/steps/letters_calls"])
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
      ]
    )
  end
end
