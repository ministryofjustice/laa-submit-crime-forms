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
        find('button.govuk-button#search').click
      end

      context 'when I search by LAA reference' do
        let(:query) { 'laa-ab1234' }

        it 'shows only the matching record that I am associated with' do
          within('.govuk-table') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search by UFN' do
        let(:query) { '070620/123' }

        it 'shows only the matching record that I am associated with' do
          within('.govuk-table') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search by first name' do
        let(:query) { 'JOE' }

        it 'shows only the matching record that I am associated with' do
          within('.govuk-table') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search by last name' do
        let(:query) { 'bloggs' }

        it 'shows only the matching record that I am associated with' do
          within('.govuk-table') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search by combo' do
        let(:query) { 'BLOGGS JOE 070620/123' }

        it 'shows only the matching record that I am associated with' do
          within('.govuk-table') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
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
        find('button.govuk-button#search').click
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

    context 'change link target based on state' do
      let(:draft) do
        create :prior_authority_application, :full,
               laa_reference: 'LAA-99999C',
               office_code: '1A123B',
               ufn: '110120/123',
               defendant: build(:defendant, :valid, first_name: 'Joe', last_name: 'Doe', date_of_birth: '1995-10-05'),
               state: :draft
      end

      let(:submitted) do
        create :prior_authority_application, :full,
               laa_reference: 'LAA-AB1234',
               office_code: '1A123B',
               ufn: '070620/123',
               defendant: build(:defendant, :valid, first_name: 'Joe', last_name: 'Bloggs', date_of_birth: '1995-10-06'),
               state: :submitted
      end

      before do
        draft
        submitted

        visit search_prior_authority_applications_path
        fill_in 'Enter any combination of client, UFN or LAA reference', with: 'Joe'
        find('button.govuk-button#search').click
      end

      it 'shows only the matching record' do
        within('#results') do
          expect(page).to have_content 'Draft'
          expect(page).to have_content 'Submitted'
        end
      end

      it 'click draft link goes to application start page step' do
        click_link '110120/123'
        expect(page).to have_content 'Your application progress'
      end

      it 'click submitted link goes to application claim details' do
        click_link '070620/123'
        expect(page).to have_content 'Application details'
      end
    end
  end

  describe 'NSM' do
    let(:matching) do
      create :claim, :complete,
             laa_reference: 'LAA-AB1234',
             office_code: 'XYZXYZ',
             ufn: '070620/123',
             main_defendant: build(:defendant, :valid, first_name: 'Joe', last_name: "Bloggs-O'Reilly"),
             state: :submitted,
             updated_at: DateTime.new(2024, 9, 1, 10, 17, 26),
             originally_submitted_at: DateTime.new(2024, 9, 1, 10, 17, 26)
    end

    let(:non_matching) do
      create :claim, :complete,
             laa_reference: 'LAA-99999C',
             office_code: '1A123B',
             ufn: '110120/123',
             main_defendant: build(:defendant, :valid, first_name: 'Jane', last_name: 'Doe'),
             state: :draft,
             updated_at: DateTime.new(2024, 10, 1, 10, 17, 26),
             originally_submitted_at: DateTime.new(2024, 10, 1, 10, 17, 26)
    end

    before do
      visit provider_saml_omniauth_callback_path
      Provider.first.update(office_codes: %w[XYZXYZ 1A123B])
    end

    context 'when finding a single result by query' do
      let(:different_office) do
        create :claim, :complete,
               laa_reference: 'LAA-AB1234',
               office_code: 'CCCCCC',
               ufn: '070620/123',
               main_defendant: build(:defendant, :valid, first_name: 'Joe', last_name: 'Bloggs'),
               state: :rejected
      end

      before do
        matching
        non_matching
        different_office

        visit search_nsm_applications_path
        fill_in 'Enter any combination of defendant, UFN or LAA reference', with: query
        find('button.govuk-button#search').click
      end

      context 'when I enter nothing' do
        let(:query) { '' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_content 'Enter some details or filter your search criteria'
        end
      end

      context 'when I search by LAA reference' do
        let(:query) { 'laa-ab1234' }

        it 'shows only the matching record that I am associated with' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search by UFN' do
        let(:query) { '070620/123' }

        it 'shows only the matching record that I am associated with' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search by first name' do
        let(:query) { 'JOE' }

        it 'shows only the matching record that I am associated with' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search by partial last name' do
        let(:query) { 'Bloggs' }

        it 'shows only the matching record that I am associated with' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search by last name' do
        let(:query) { "Bloggs-O'Reilly" }

        it 'shows only the matching record that I am associated with' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search by combo' do
        let(:query) { "BLOGGS-O'REILLY JOE 070620/123" }

        it 'shows only the matching record that I am associated with' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search for unmatched parentheses' do
        let(:query) { 'Joe)' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_no_content 'Something went wrong trying to perform this search'

          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end

      context 'when I search for a query with ampersands' do
        let(:query) { '&' }

        it 'shows only the matching record that I am associated with' do
          expect(page).to have_no_content 'Something went wrong trying to perform this search'

          within('#results') do
            expect(page).to have_no_content 'Submitted'
            expect(page).to have_no_content 'Draft'
            expect(page).to have_no_content 'Rejected'
          end
        end
      end
    end

    context 'when filtering' do
      before do
        matching
        non_matching

        visit search_nsm_applications_path
      end

      context 'when I filter by submission date' do
        before do
          fill_in 'Submission date from', with: '2024-09-01'
          fill_in 'Submission date to', with: '2024-09-01'
          find('button.govuk-button#search').click
        end

        it 'shows only the matching record' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
          end
        end
      end

      context 'when I filter by submission from date' do
        before do
          fill_in 'Submission date from', with: '2024-10-01'
          find('button.govuk-button#search').click
        end

        it 'shows only the matching record' do
          within('#results') do
            expect(page).to have_content 'Draft'
            expect(page).to have_no_content 'Submitted'
          end
        end
      end

      context 'when I filter by submission to date' do
        before do
          fill_in 'Submission date to', with: '2024-09-02'
          find('button.govuk-button#search').click
        end

        it 'shows only the matching record' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
          end
        end
      end

      context 'when I filter by update date' do
        before do
          fill_in 'Last updated from', with: '2024-09-01'
          fill_in 'Last updated to', with: '2024-09-01'
          find('button.govuk-button#search').click
        end

        it 'shows only the matching record' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
          end
        end
      end

      context 'when I filter by update from date' do
        before do
          fill_in 'Last updated from', with: '2024-09-02'
          find('button.govuk-button#search').click
        end

        it 'shows only the matching record' do
          within('#results') do
            expect(page).to have_content 'Draft'
            expect(page).to have_no_content 'Submitted'
          end
        end
      end

      context 'when I filter by update to date' do
        before do
          fill_in 'Last updated to', with: '2024-09-01'
          find('button.govuk-button#search').click
        end

        it 'shows only the matching record' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
          end
        end
      end

      context 'when I filter by state' do
        before do
          select 'Submitted', from: 'Application status'
          find('button.govuk-button#search').click
        end

        it 'shows only the matching record' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
          end
        end
      end

      context 'when filtering by granted' do
        before do
          matching.granted!

          select 'Granted', from: 'Application status'
          find('button.govuk-button#search').click
        end

        it 'shows only the matching record' do
          within('#results') do
            expect(page).to have_content 'Granted'
            expect(page).to have_no_content 'Draft'
          end
        end
      end

      context 'when I filter by office code' do
        before do
          select 'XYZXYZ', from: 'Account'
          find('button.govuk-button#search').click
        end

        it 'shows only the matching record' do
          within('#results') do
            expect(page).to have_content 'Submitted'
            expect(page).to have_no_content 'Draft'
          end
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
        fill_in 'Enter any combination of defendant, UFN or LAA reference', with: 'Joe Bloggs'
        find('button.govuk-button#search').click
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
