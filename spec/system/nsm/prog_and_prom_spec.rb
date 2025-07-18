require 'system_helper'

RSpec.describe 'Prog/prom calculation', :stub_app_store_search, :stub_oauth_token, type: :system do
  before do
    visit provider_entra_id_omniauth_callback_path
    click_on "Claim non-standard magistrates' court payments, previously CRM7"
    click_on 'Start a new claim'
    fill_in 'What is your unique file number (UFN)?', with: '120223/001'
  end

  context 'when I claim for breach of injunction' do
    before do
      choose 'Breach of injunction'
      fill_in 'Clients CNTP (contempt) number', with: '123456'
      within('.govuk-radios__conditional', text: 'Date the CNTP rep order was issued') do
        fill_in 'Day', with: '20'
        fill_in 'Month', with: '4'
        fill_in 'Year', with: '2023'
      end
      click_on 'Save and continue'

      first('.govuk-radios__label').click
      click_on 'Save and continue'
    end

    it 'takes me to the task list' do
      expect(page).to have_content 'Your claim progress'
    end

    it 'knows the stage reached is prog' do
      expect(page).to have_content 'Stage reached PROG'
    end
  end

  context 'when I claim for a court payment' do
    before do
      choose "Non-standard magistrates' court payment"
      within('.govuk-radios__conditional', text: 'Representation order date') do
        fill_in 'Day', with: '20'
        fill_in 'Month', with: '4'
        fill_in 'Year', with: '2023'
      end

      click_on 'Save and continue'

      first('.govuk-radios__label').click
      click_on 'Save and continue'
    end

    it 'takes me to the office area page' do
      expect(page).to have_content 'Was this case worked on in an office in an undesignated area?'
    end

    context 'when I click back' do
      before { click_on 'Back' }

      it 'takes me back to the claim type screen' do
        expect(page).to have_content I18n.t('.nsm.steps.office_code.edit.page_title')
      end
    end

    context 'when I say yes to office in undesignated area' do
      before do
        choose 'Yes'
        click_on 'Save and continue'
      end

      it 'takes me to the court area page' do
        expect(page).to have_content 'Is the first court that heard this case in an undesignated area?'
      end

      context 'when I click back' do
        before { click_on 'Back' }

        it 'takes me back to the office area screen' do
          expect(page).to have_content 'Was this case worked on in an office in an undesignated area?'
        end
      end

      context 'when I say yes to court in undesignated area' do
        before do
          choose 'Yes'
          click_on 'Save and continue'
        end

        it 'takes me to the task list' do
          expect(page).to have_content 'Your claim progress'
        end

        it 'knows the stage reached is prog' do
          expect(page).to have_content 'Stage reached PROG'
        end
      end

      context 'when I say no to court in undesignated area' do
        before do
          choose 'No'
          click_on 'Save and continue'
        end

        it 'takes me to the case transfer screen' do
          expect(page).to have_content 'Was this case transferred to a court in an undesignated area?'
        end

        context 'when I click back' do
          before { click_on 'Back' }

          it 'takes me back to the court area screen' do
            expect(page).to have_content 'Is the first court that heard this case in an undesignated area?'
          end
        end

        context 'when I say yes to case transfer' do
          before do
            choose 'Yes'
            click_on 'Save and continue'
          end

          it 'takes me to the task list' do
            expect(page).to have_content 'Your claim progress'
          end

          it 'knows the stage reached is prog' do
            expect(page).to have_content 'Stage reached PROG'
          end
        end

        context 'when I say no to case transfer' do
          before do
            choose 'No'
            click_on 'Save and continue'
          end

          it 'takes me to the task list' do
            expect(page).to have_content 'Your claim progress'
          end

          it 'knows the stage reached is prom' do
            expect(page).to have_content 'Stage reached PROM'
          end
        end
      end
    end

    context 'when I say no to office in undesignated area' do
      before do
        choose 'No'
        click_on 'Save and continue'
      end

      it 'takes me to the task list' do
        expect(page).to have_content 'Your claim progress'
      end

      it 'knows the stage reached is prom' do
        expect(page).to have_content 'Stage reached PROM'
      end
    end
  end
end
