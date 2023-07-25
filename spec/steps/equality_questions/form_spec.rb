require 'rails_helper'

RSpec.describe Steps::EqualityQuestionsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      gender:,
      ethnic_group:,
      disability:
    }
  end

  let(:application) { double(:application) }
  let(:gender) { Genders.values.sample.to_s }
  let(:ethnic_group) { EthnicGroups.values.sample.to_s }
  let(:disability) { Disabilities.values.sample.to_s }

  describe '#validations' do
    it { expect(subject).to be_valid }

    %i[gender ethnic_group disability].each do |field|
      context "when #{field} is blank" do
        let(field) { '' }

        it { expect(subject).to be_valid }
      end

      context "when #{field} is nil" do
        let(field) { nil }

        it { expect(subject).to be_valid }
      end

      context "when #{field} is unknown value" do
        let(field) { 'apples' }

        it 'to have errors' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(field, :inclusion)).to be(true)
        end
      end
    end
  end
end
