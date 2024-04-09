require 'system_helper'

RSpec.describe 'Prior authority applications - alternative quote' do
  let(:application) do
    create(:prior_authority_application, :with_primary_quote)
  end

  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_steps_start_page_path(application)
  end

  context 'when I visit the quote summary screen' do
    before do
      click_on 'Alternative quotes'
    end

    it 'lets me add no quotes' do
      choose 'No'
      fill_in 'Why did you not get other quotes?', with: 'Some reason'
      click_on 'Save and continue'
      expect(page).to have_content 'Alternative quotesCompleted'
    end

    it 'validates appropriately' do
      choose 'No'
      click_on 'Save and continue'
      expect(page).to have_content 'Explain why you did not get other quotes'
    end

    context 'when I click through to add alternative quotes' do
      before do
        choose 'Yes'
        click_on 'Save and continue'
      end

      it 'allows me to add an alternative quote' do
        fill_in 'First name', with: 'Mrs'
        fill_in 'Last name', with: 'Expert'
        fill_in 'Organisation', with: 'ExpertiseCo'
        fill_in 'Postcode', with: 'SW1 1AA'
        choose 'Charged per item'
        fill_in 'Number of items', with: '2'
        fill_in 'What is the cost per item?', with: '3'
        click_on 'Save and continue'

        expect(page).to have_content "You've added 1 alternative quote"
        expect(page).to have_content 'Mrs Expert'
      end

      it 'allows me to add a quote with a file' do
        fill_in 'First name', with: 'Mrs'
        fill_in 'Last name', with: 'Expert'
        fill_in 'Organisation', with: 'ExpertiseCo'
        fill_in 'Postcode', with: 'SW1 1AA'
        choose 'Charged per item'
        fill_in 'Number of items', with: '2'
        fill_in 'What is the cost per item?', with: '3'
        attach_file(file_fixture('test.png'))
        click_on 'Save and continue'

        expect(page).to have_content "You've added 1 alternative quote"
        expect(page).to have_content 'test.png'
      end

      it 'does maths for me' do
        fill_in 'First name', with: 'Mrs'
        fill_in 'Last name', with: 'Expert'
        fill_in 'Organisation', with: 'ExpertiseCo'
        fill_in 'Postcode', with: 'SW1 1AA'
        choose 'Charged per item'
        fill_in 'Number of items', with: '1'
        fill_in 'What is the cost per item?', with: '100'
        fill_in 'prior_authority_steps_alternative_quotes_detail_form_travel_time_1', with: '1'
        fill_in 'prior_authority_steps_alternative_quotes_detail_form_travel_time_2', with: '0'
        fill_in 'What is the hourly cost?', with: '50'
        fill_in 'Total additional costs', with: '5'
        click_on 'Update calculation'

        expect(page).to have_content 'Total quote cost £155.00'
      end

      it 'validates' do
        click_on 'Save and continue'
        expect(page).to have_content "Enter the service provider's first name"
      end

      context 'When I have added a quote' do
        before do
          fill_in 'First name', with: 'Mrs'
          fill_in 'Last name', with: 'Expert'
          fill_in 'Organisation', with: 'ExpertiseCo'
          fill_in 'Postcode', with: 'SW1 1AA'
          choose 'Charged per item'
          fill_in 'Number of items', with: '2'
          fill_in 'What is the cost per item?', with: '3'
          click_on 'Save and continue'
        end

        it 'allows me to edit a quote' do
          click_on 'Change'

          fill_in 'First name', with: 'Mr'
          click_on 'Save and continue'

          expect(page).to have_content "You've added 1 alternative quote"
          expect(page).to have_content 'Mr Expert'
        end

        it 'allows me to move on' do
          choose 'No'
          click_on 'Save and continue'

          expect(page).to have_content 'Alternative quotesCompleted'
        end

        it 'allows me to remove a quote' do
          click_on 'Delete'
          expect(page).to have_content 'Are you sure you want to delete this alternative quote?'
          click_on 'Yes, delete it'
          expect(page).to have_content 'The alternative quote was deleted'
          expect(page).to have_content 'Do you want to add an additional quote?'
        end

        it 'allows me to cancel deletion' do
          click_on 'Delete'
          click_on 'No, do not delete it'
          expect(page).to have_content "You've added 1 alternative quote"
        end

        it 'deletes the quote if it is invalidated by a service type change' do
          choose 'No'
          click_on 'Save and continue'
          click_on 'Primary quote'
          within '#service-cost-card' do
            click_on 'Change'
          end
          # Charged per hour, not per item
          select 'Animal behaviourist', from: 'Service required'
          click_on 'Save and continue'
          fill_in_service_cost(cost_type: :per_hour)

          # Leave primary quote summary screen
          click_on 'Save and continue'
          expect(page).to have_content 'Alternative quotesIn progress'
        end
      end
    end
  end

  context 'when I already have 3 quotes' do
    before do
      create_list(:quote, 3, :alternative, prior_authority_application: application)
    end

    it 'does not prompt me to add more' do
      click_on 'Alternative quotes'
      click_on 'Save and continue'
      expect(page).to have_content 'Alternative quotesCompleted'
    end
  end

  context 'when i have a item type specific primary quote' do
    let(:application) do
      create(:prior_authority_application, :with_primary_quote_per_item, service_type:)
    end

    before do
      click_on 'Alternative quotes'
      choose 'Yes'
      click_on 'Save and continue'
    end

    context 'with Translation (documents) service' do
      let(:service_type) { 'translation_documents' }

      it 'asks a question about words' do
        expect(page).to have_content 'What is the cost per word?'
      end

      it 'validates appropriately with partial data' do
        click_on 'Save and continue'
        expect(page)
          .to have_content('Enter the number of words')
          .and have_content('Enter the cost per word')
      end
    end

    context 'with Photocopying service' do
      let(:service_type) { 'photocopying' }

      it 'asks a question about pages' do
        expect(page).to have_content 'What is the cost per page?'
      end

      it 'validates appropriately with partial data' do
        click_on 'Save and continue'
        expect(page)
          .to have_content('Enter the number of pages')
          .and have_content('Enter the cost per page')
      end
    end

    context 'with Translation and transcription service' do
      let(:service_type) { 'translation_and_transcription' }

      it 'asks a question about minutes' do
        expect(page).to have_content 'What is the cost per minute?'
      end

      it 'validates appropriately with partial data' do
        click_on 'Save and continue'
        expect(page)
          .to have_content('Enter the number of minutes')
          .and have_content('Enter the cost per minute')
      end
    end
  end
end
