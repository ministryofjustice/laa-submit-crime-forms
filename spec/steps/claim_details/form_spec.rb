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

  describe '#save preparation time yes' do
    context 'when all fields are set and preparation_time set to yes' do
      let(:preparation_time) { 'yes' }
      let(:time_spent_hours) { 2 }
      let(:time_spent_mins) { 40 }

      it 'is valid' do
        expect(form.save).to be_truthy
        expect(application).to have_received(:update!)
        expect(form).to be_valid
      end
    end
  end

  describe '#save preparation no' do
    context 'when all fields are set and preparation_time set to no' do
      let(:preparation_time) { 'no' }
      let(:time_spent_hours) { nil }
      let(:time_spent_mins) { nil }

      it 'is valid' do
        expect(form.save).to be_truthy
        expect(application).to have_received(:update!)
        expect(form).to be_valid
      end
    end
  end

  describe '#valid? preparation yes' do
    context 'when all fields are set' do
      let(:preparation_time) { 'yes' }
      let(:time_spent_hours) { 2 }
      let(:time_spent_mins) { 40 }

      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end

  describe '#valid? preparation no' do
    context 'when all fields are set' do
      let(:preparation_time) { 'no' }
      let(:time_spent_hours) { nil }
      let(:time_spent_mins) { nil }

      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end

  describe '#invalid? preparation yes' do
    context 'when all fields are set' do
      let(:preparation_time) { 'yes' }
      let(:time_spent_hours) { nil }
      let(:time_spent_mins) { nil }

      it 'is invalid' do
        expect(form).not_to be_valid
      end
    end
  end
end
