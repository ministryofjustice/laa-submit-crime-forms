require 'rails_helper'

RSpec.describe Steps::ClaimDetailsForm do
  let(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      application:,
      prosecution_evidence:,
      defence_statement:,
      number_of_witnesses:,
      supplemental_claim:,
      preparation_time:,
      time_spent_hours:,
      time_spent_mins:,
    }
  end

  let(:application) { instance_double(Claim, update!: true) }

  let(:prosecution_evidence) { 'prosection evidence' }
  let(:defence_statement) { 'defence statement' }
  let(:number_of_witnesses) { 1 }
  let(:supplemental_claim) { 'yes' }
  let(:preparation_time) { 'yes' }
  let(:time_spent_hours) { 2 }
  let(:time_spent_mins) { 40 }

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
