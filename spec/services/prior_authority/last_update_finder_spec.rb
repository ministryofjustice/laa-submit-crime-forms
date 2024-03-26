require 'rails_helper'

RSpec.describe PriorAuthority::LastUpdateFinder do
  describe '.call' do
    subject(:finder) { described_class.call(application) }

    let(:application) do
      travel_to(sent_back_datetime) do
        create(:prior_authority_application,
               :with_all_tasks_completed,
               :with_firm_and_solicitor,
               :with_alternative_quotes,
               :with_sent_back_status)
      end
    end

    let(:sent_back_datetime) { 2.days.ago.change({ hour: 11, minute: 0 }) }
    let(:updated_datetime) { 0.days.ago.change({ hour: 10, minute: 0 }) }

    before do
      application
    end

    context 'when not updated' do
      it 'returns the date application was sent back' do
        expect(finder).to eql(sent_back_datetime)
      end
    end

    context 'when provider updated' do
      before do
        travel_to(updated_datetime) do
          application.provider.update!(email: 'someone-else@provider.com')
        end
      end

      it 'excludes provider updated date' do
        expect(finder).to eql(sent_back_datetime)
      end
    end

    context 'when firm_office updated' do
      before do
        travel_to(updated_datetime) do
          application.firm_office.update!(account_number: '2BON2B')
        end
      end

      let(:updated_datetime) { 0.days.ago.change({ hour: 6, minute: 0 }) }

      it 'returns the date of the update of the firm_office' do
        expect(finder).to eql(updated_datetime)
      end
    end

    context 'with changed application details' do
      before do
        travel_to(updated_datetime) do
          application.update!(subject_to_poca: true)
        end
      end

      let(:updated_datetime) { 0.days.ago.change({ hour: 10, minute: 0 }) }

      it 'returns the date of the update of the application' do
        expect(finder).to eql(updated_datetime)
      end
    end

    context 'with changed solicitor details' do
      before do
        travel_to(updated_datetime) do
          application.solicitor.update!(contact_email: 'billy-bob@pga-law.com')
        end
      end

      let(:updated_datetime) { 0.days.ago.change({ hour: 8, minute: 0 }) }

      it 'returns the date of the update of the solicitor' do
        expect(finder).to eql(updated_datetime)
      end
    end

    context 'with changed defendant details' do
      before do
        travel_to(updated_datetime) do
          application.defendant.update!(date_of_birth: Date.new(2001, 1, 1))
        end
      end

      let(:updated_datetime) { 0.days.ago.change({ hour: 7, minute: 30 }) }

      it 'returns the date of the update of the defendant' do
        expect(finder).to eql(updated_datetime)
      end
    end

    context 'with changed primary quote details' do
      before do
        travel_to(updated_datetime) do
          application.primary_quote.update!(postcode: 'SW1A 2AA')
        end
      end

      let(:updated_datetime) { 0.days.ago.change({ hour: 9, minute: 0 }) }

      it 'returns the date of the update of the primary quote' do
        expect(finder).to eql(updated_datetime)
      end
    end

    context 'with changed alternative quote details' do
      before do
        travel_to(updated_datetime) do
          application.alternative_quotes.first.update!(organisation: 'Some other company')
        end
      end

      let(:updated_datetime) { 0.days.ago.change({ hour: 12, minute: 0 }) }

      it 'returns the date of the update of the alternative quote' do
        expect(finder).to eql(updated_datetime)
      end
    end

    context 'with additional alternative quote' do
      before do
        travel_to(updated_datetime) do
          application.alternative_quotes << build(:quote, :alternative)
        end
      end

      let(:updated_datetime) { 0.days.ago.change({ hour: 14, minute: 0 }) }

      it 'returns the date the additional alternative quote was created/updated' do
        expect(finder).to eql(updated_datetime)
      end
    end

    context 'with additional supporting document' do
      before do
        travel_to(updated_datetime) do
          application.supporting_documents << build(:supporting_document)
        end
      end

      let(:updated_datetime) { 0.days.ago.change({ hour: 12, minute: 0 }) }

      it 'returns the date the additional supporting document was created/updated' do
        expect(finder).to eql(updated_datetime)
      end
    end
  end
end
