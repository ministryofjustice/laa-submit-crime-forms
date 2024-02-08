require 'system_helper'

RSpec.describe 'Prior authority applications - add service costs' do
  before do
    fill_in_until_step(:primary_quote)
    click_on 'Primary quote'
    fill_in_primary_quote(service_type:)
    expect(page).to have_title 'Service cost'
  end

  let(:service_type) { 'Meteorologist' }

  context 'when the service is Psychiatric report (Prison Law)' do
    let(:service_type) { 'Psychiatric report (Prison Law)' }

    it 'asks a court order question' do
      expect(page).to have_content 'Was this report ordered by the court?'
    end
  end

  context 'when the service is Pathologist report' do
    let(:service_type) { 'Pathologist report' }

    it 'asks a pathologist report question' do
      expect(page).to have_content 'Is this related to a post-mortem?'
    end
  end

  context 'when the service is Transcription (recording)' do
    let(:service_type) { 'Transcription (recording)' }

    it 'asks a question about minutes' do
      expect(page).to have_content 'What is the cost per minute?'
    end
  end

  context 'when the service is Translator' do
    let(:service_type) { 'Translator' }

    it 'asks a question about words' do
      expect(page).to have_content 'What is the cost per word?'
    end
  end

  context 'when the service is Photocopying' do
    let(:service_type) { 'Photocopying' }

    it 'asks a question about words' do
      expect(page).to have_content 'What is the cost per page?'
    end
  end

  context 'when the service is DNA Report' do
    let(:service_type) { 'DNA Report' }

    it 'asks a question about cost type' do
      expect(page).to have_content 'How are you being charged?'
    end
  end

  context 'when the service is Cardiologist' do
    let(:service_type) { 'Cardiologist' }

    it 'asks a question about hours' do
      expect(page).to have_content 'Hourly cost'
    end
  end

  it 'validates appropriately with nothing entered' do
    click_on 'Save and continue'
    expect(page).to have_content(
      'Select yes if you have already been granted prior authority in this case for the same type of service'
    )
    expect(page).to have_content 'Select how you are being charged'
  end

  it 'validates appropriately with partial data' do
    choose 'No'
    choose 'Charged by the hour'
    click_on 'Save and continue'
    expect(page).to have_content 'Enter the time'
    expect(page).to have_content 'Enter the hourly cost'
  end

  it 'updates the calculation on demand for item costs' do
    choose 'Charged per item'
    fill_in 'Number of items', with: '5'
    fill_in 'What is the cost per item?', with: '1.23'
    click_on 'Update calculation'
    expect(page).to have_content '£6.15'
  end

  it 'updates the calculation on demand for time costs' do
    choose 'Charged by the hour'
    fill_in 'Hours', with: '1'
    fill_in 'Minutes', with: '15'
    fill_in 'Hourly cost', with: '60'
    click_on 'Update calculation'
    expect(page).to have_content '£75'
  end

  it 'persists my answers' do
    choose 'Yes'
    choose 'Charged per item'
    fill_in 'Number of items', with: '5'
    fill_in 'What is the cost per item?', with: '1.23'
    click_on 'Save and continue'
    quote = Quote.last
    expect(quote.items).to eq 5
    expect(quote.user_chosen_cost_type).to eq 'per_item'
    expect(quote.cost_per_item).to eq 1.23
    expect(quote.prior_authority_application.prior_authority_granted).to be true
  end
end
