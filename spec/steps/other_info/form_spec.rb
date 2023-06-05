require 'rails_helper'

RSpec.describe Steps::OtherInfoForm do
  let(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      application:,
      other_info:,
      conclusion:,
      concluded:,
    }
  end

  let(:application) { instance_double(Claim, update!: true) }
  let(:other_info) { 'other relevent information' }
  let(:conclusion) { 'conclusion' }
  let(:concluded) { 'yes' }

  describe '#save' do
    context 'when all fields are set' do
      it 'is valid' do
        expect(form.save).to be_truthy
        expect(application).to have_received(:update!)
        expect(form).to be_valid
      end
    end
  end

  describe '#valid?' do
    context 'when all fields are set' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end
end
