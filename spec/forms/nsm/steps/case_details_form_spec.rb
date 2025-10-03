require 'rails_helper'

RSpec.describe Nsm::Steps::CaseDetailsForm do
  let(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      application:,
      main_offence:,
      main_offence_type:,
      main_offence_date:,
      assigned_counsel:,
      unassigned_counsel:,
      agent_instructed:,
      remitted_to_magistrate:,
      remitted_to_magistrate_date:,
    }
  end

  let(:application) { instance_double(Claim, update!: true) }

  let(:main_offence) { LaaCrimeFormsCommon::MainOffence.all.sample.name }
  let(:main_offence_date) { Date.new(2023, 4, 1) }
  let(:main_offence_type) { 'summary_only' }
  let(:unassigned_counsel) { 'no' }
  let(:assigned_counsel) { 'yes' }
  let(:agent_instructed) { 'yes' }
  let(:remitted_to_magistrate) { 'no' }
  let(:remitted_to_magistrate_date) { nil }

  describe '#save' do
    let(:application) { build(:claim) }

    context 'when all fields are set' do
      it 'is valid' do
        expect(form.save).to be_truthy
      end
    end

    context 'when remitted_to_magistrate with invalid remitted_to_magistrate_date' do
      let(:remitted_to_magistrate_date) { { 1 => '1', 2 => '13', 3 => '2024' } }

      it 'is valid' do
        expect(form.save).to be_truthy
        expect(application.reload).to have_attributes(
          remitted_to_magistrate: 'no',
          remitted_to_magistrate_date: nil
        )
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

  describe '#invalid?' do
    %i[ main_offence main_offence_type main_offence_date assigned_counsel unassigned_counsel agent_instructed
        remitted_to_magistrate].each do |field|
      context "when #{field} is missing" do
        let(field) { nil }

        it 'is valid' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(field, :blank)).to be(true)
        end
      end
    end
  end

  context 'when `main_offence_type` is invalid' do
    let(:main_offence_type) { 'invalid_type' }

    it 'has a validation error on the field' do
      expect(subject).not_to be_valid
      expect(subject.errors.of_kind?(:main_offence_type, :inclusion)).to be(true)
    end
  end

  context 'when main_offence_suggestion is not provided' do
    subject { described_class.new(arguments.merge(main_offence:)) }

    it 'main_offence not provided' do
      expect(subject.main_offence).to eq(main_offence)
    end
  end

  context 'when main_offence_suggestion is provided' do
    subject { described_class.new(arguments.merge(main_offence_suggestion:)) }

    let(:main_offence_suggestion) { 'apples' }

    it 'main_offence is provided' do
      expect(subject.main_offence).to eq('apples')
    end
  end

  context 'when remitted to magistrate is provided' do
    subject { described_class.new(arguments.merge(main_offence_suggestion:)) }

    let(:remitted_to_magistrate_date) { Date.yesterday }
    let(:remitted_to_magistrate) { 'yes' }

    it 'magistrate date is provided' do
      expect(form).to be_valid
    end
  end

  context 'when remitted to magistrate date is not provided' do
    subject { described_class.new(arguments.merge(main_offence_suggestion:)) }

    let(:remitted_to_magistrate) { 'yes' }
    let(:remitted_to_magistrate_date) { nil }

    it 'magistrate date is not provided' do
      expect(form).not_to be_valid
      expect(form.errors.of_kind?(:remitted_to_magistrate_date, :blank)).to be(true)
    end
  end
end
