require 'rails_helper'

RSpec.describe Tasks::FirmDetails, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.new(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      firm_office: firm_office,
      solicitor: solicitor,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:firm_office) { nil }
  let(:solicitor) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/firm_details") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    it { expect(subject).to be_can_start }
  end

  describe '#completed?' do
    context 'when all solicitor or firm_details fields are nil' do
      it { expect(subject).not_to be_completed }
    end

    context 'when all solicitor and firm_details fields are set' do
      let(:firm_office) do
        FirmOffice.new(
          'name' => 'Law',
          'account_number' => 'l1',
          'address_line_1' => '20 road',
          'town' => 'city',
          'postcode' => 'AAA1 BB2',
        )
      end
      let(:solicitor) { Solicitor.new('full_name' => 'jim', 'reference_number' => 'jbob') }

      context 'when all required fields are present' do
        it { expect(subject).to be_completed }
      end

      context 'when any required fields are missing' do
        %w[name account_number address_line_1 town postcode].each do |field|
          it "is not completed when firm_office.#{field} is nil" do
            firm_office[field] = nil
            expect(subject).not_to be_completed
          end
        end

        %w[full_name reference_number].each do |field|
          it "is not completed when solicitor.#{field} is nil" do
            solicitor[field] = nil
            expect(subject).not_to be_completed
          end
        end
      end
    end
  end
end
