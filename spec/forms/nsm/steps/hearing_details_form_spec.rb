require 'rails_helper'

RSpec.describe Nsm::Steps::HearingDetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      first_hearing_date:,
      number_of_hearing:,
      court:,
      youth_court:,
      hearing_outcome:,
      matter_type:,
    }
  end

  let(:application) { instance_double(Claim, update!: true) }
  let(:first_hearing_date) { Date.yesterday }
  let(:number_of_hearing) { 1 }
  let(:court) { LaaCrimeFormsCommon::Court.all.sample.name }
  let(:youth_court) { 'no' }
  let(:hearing_outcome) { LaaCrimeFormsCommon::OutcomeCode.all.sample.id }
  let(:matter_type) { LaaCrimeFormsCommon::MatterType.all.sample.id }

  describe '#save' do
    context 'when all fields are provided' do
      it 'returns true' do
        expect(subject.save).to be(true)
      end
    end

    %i[
      first_hearing_date
      number_of_hearing
      court
      youth_court
      hearing_outcome
      matter_type
    ].each do |field|
      context "when `#{field}` is not provided" do
        let(field) { nil }

        it 'returns false' do
          expect(subject.save).to be(false)
        end

        it 'has a validation error on the field' do
          subject.save
          expect(subject.errors.of_kind?(field, :blank)).to be(true)
        end
      end
    end
  end

  describe 'court' do
    context 'when court_suggestion is not provided' do
      it { expect(subject.court).to eq(court) }
    end

    context 'when court_suggestion is provided' do
      subject { described_class.new(arguments.merge(court_suggestion:)) }

      let(:court_suggestion) { 'apples' }

      it { expect(subject.court).to eq('apples - n/a') }
    end
  end
end
