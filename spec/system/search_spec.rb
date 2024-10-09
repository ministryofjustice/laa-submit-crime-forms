require 'system_helper'

RSpec.describe 'Search' do
  describe 'PA' do
    let(:matching) do
      create :prior_authority_application, :full,
             laa_reference: 'LAA-AB1234',
             office_code: '1A123B',
             ufn: '070620/123',
             defendant: build(:defendant, :valid, first_name: 'Joe', last_name: 'Bloggs'),
             state: :submitted
    end

    before { visit provider_saml_omniauth_callback_path }

    context 'when finding a single result' do
      let(:different_office) do
        create :prior_authority_application, :full,
               laa_reference: 'LAA-AB1234',
               office_code: 'CCCCCC',
               ufn: '070620/123',
               defendant: build(:defendant, :valid, first_name: 'Joe', last_name: 'Bloggs'),
               state: :rejected
      end

      let(:non_matching) do
        create :prior_authority_application, :full,
               laa_reference: 'LAA-99999C',
               office_code: '1A123B',
               ufn: '110120/123',
               defendant: build(:defendant, :valid, first_name: 'Jane', last_name: 'Doe'),
               state: :draft
      end

      before do
        matching
        non_matching
        different_office

        visit search_prior_authority_applications_path
        fill_in 'Enter any combination of client, UFN or LAA reference', with: query
        click_on 'Search'
      end

      context 'when I search by LAA reference' do
        let(:query) { 'laa-ab1234' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Submitted'
          expect(page).to have_no_content 'Draft'
          expect(page).to have_no_content 'Rejected'
        end
      end

      context 'when I search by UFN' do
        let(:query) { '070620/123' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Submitted'
          expect(page).to have_no_content 'Draft'
          expect(page).to have_no_content 'Rejected'
        end
      end

      context 'when I search by first name' do
        let(:query) { 'JOE' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Submitted'
          expect(page).to have_no_content 'Draft'
          expect(page).to have_no_content 'Rejected'
        end
      end

      context 'when I search by last name' do
        let(:query) { 'bloggs' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Submitted'
          expect(page).to have_no_content 'Draft'
          expect(page).to have_no_content 'Rejected'
        end
      end

      context 'when I search by combo' do
        let(:query) { 'BLOGGS JOE 070620/123' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Submitted'
          expect(page).to have_no_content 'Draft'
          expect(page).to have_no_content 'Rejected'
        end
      end
    end

    context 'when there are multiple results' do
      let(:other_matching) do
        create :prior_authority_application, :full,
               laa_reference: 'LAA-EE1234',
               office_code: '1A123B',
               ufn: '060620/999',
               defendant: build(:defendant, :valid, first_name: 'Joe', last_name: 'Bloggs'),
               state: :submitted,
               updated_at: 1.year.ago
      end

      before do
        matching
        other_matching

        visit search_prior_authority_applications_path
        fill_in 'Enter any combination of client, UFN or LAA reference', with: 'Joe Bloggs'
        click_on 'Search'
      end

      it 'sorts by updated at by default' do
        expect(page).to have_content(/AB1234.*EE1234.*/m)
      end

      it 'allows me to reverse the order' do
        click_link 'Last updated'
        expect(page).to have_content(/EE1234.*AB1234.*/m)
      end

      it 'allows me to sort by UFN' do
        click_link 'UFN'
        expect(page).to have_content(/EE1234.*AB1234.*/m)
      end
    end
  end

  describe 'NSM' do
    let(:matching) do
      create :claim, :complete,
             laa_reference: 'LAA-AB1234',
             office_code: '1A123B',
             ufn: '070620/123',
             main_defendant: build(:defendant, :valid, first_name: 'Joe', last_name: 'Bloggs'),
             state: :submitted
    end

    before { visit provider_saml_omniauth_callback_path }

    context 'when finding a single result' do
      let(:different_office) do
        create :claim, :complete,
               laa_reference: 'LAA-AB1234',
               office_code: 'CCCCCC',
               ufn: '070620/123',
               main_defendant: build(:defendant, :valid, first_name: 'Joe', last_name: 'Bloggs'),
               state: :rejected
      end

      let(:non_matching) do
        create :claim, :complete,
               laa_reference: 'LAA-99999C',
               office_code: '1A123B',
               ufn: '110120/123',
               main_defendant: build(:defendant, :valid, first_name: 'Jane', last_name: 'Doe'),
               state: :draft
      end

      before do
        matching
        non_matching
        different_office

        visit search_nsm_applications_path
        fill_in 'Enter any combination of client, UFN or LAA reference', with: query
        click_on 'Search'
      end

      context 'when I search by LAA reference' do
        let(:query) { 'laa-ab1234' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Submitted'
          expect(page).to have_no_content 'Draft'
          expect(page).to have_no_content 'Rejected'
        end
      end

      context 'when I search by UFN' do
        let(:query) { '070620/123' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Submitted'
          expect(page).to have_no_content 'Draft'
          expect(page).to have_no_content 'Rejected'
        end
      end

      context 'when I search by first name' do
        let(:query) { 'JOE' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Submitted'
          expect(page).to have_no_content 'Draft'
          expect(page).to have_no_content 'Rejected'
        end
      end

      context 'when I search by last name' do
        let(:query) { 'bloggs' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Submitted'
          expect(page).to have_no_content 'Draft'
          expect(page).to have_no_content 'Rejected'
        end
      end

      context 'when I search by combo' do
        let(:query) { 'BLOGGS JOE 070620/123' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Submitted'
          expect(page).to have_no_content 'Draft'
          expect(page).to have_no_content 'Rejected'
        end
      end
    end

    context 'when there are multiple results' do
      let(:other_matching) do
        create :claim, :complete,
               laa_reference: 'LAA-EE1234',
               office_code: '1A123B',
               ufn: '060620/999',
               main_defendant: build(:defendant, :valid, first_name: 'Joe', last_name: 'Bloggs'),
               state: :submitted,
               updated_at: 1.year.ago
      end

      before do
        matching
        other_matching

        visit search_nsm_applications_path
        fill_in 'Enter any combination of client, UFN or LAA reference', with: 'Joe Bloggs'
        click_on 'Search'
      end

      it 'sorts by updated at by default' do
        expect(page).to have_content(/AB1234.*EE1234.*/m)
      end

      it 'allows me to reverse the order' do
        click_link 'Last updated'
        expect(page).to have_content(/EE1234.*AB1234.*/m)
      end

      it 'allows me to sort by UFN' do
        click_link 'UFN'
        expect(page).to have_content(/EE1234.*AB1234.*/m)
      end
    end
  end
end
