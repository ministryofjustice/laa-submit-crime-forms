require 'rails_helper'

RSpec.describe Steps::DefendantsDetailsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      defendants_attributes:,
    }
  end

  let(:application) { instance_double(Claim, update!: true, claim_type: claim_type, defendants: defendants) }
  let(:claim_type) { ClaimType::NON_STANDARD_MAGISTRATE }
  let(:defendants) { [] }
  let(:defendants_attributes) { nil }

  describe '#defendants' do
    context 'when defendants_attributes is set' do
      let(:defendants_attributes) { { '0' => { 'full_name' => 'Jim', 'position' => '1' } } }

      it 'builds the defendants from the attributes' do
        expect(subject.defendants.count).to eq(1)
        expect(subject.defendants.first).to have_attributes(
          id: nil,
          full_name: 'Jim',
          maat: nil,
          position: 1,
          main: false,
        )
      end

      context 'when defendants already exist in the DB' do
        let(:defendants) { [Defendant.new(full_name: 'Jake', position: '1')] }

        it 'they are ignored as defendants_attributes take precident' do
          expect(subject.defendants.count).to eq(1)
          expect(subject.defendants.first).to have_attributes(
            id: nil,
            full_name: 'Jim',
            maat: nil,
            position: 1,
            main: false,
          )
        end
      end
    end

    context 'when defendants_attributes is not set but defendants is' do |_variable|
      let(:defendants) { [Defendant.new(full_name: 'Jake', position: '1')] }

      it 'builds the defendants from the DB' do
        expect(subject.defendants.count).to eq(1)
        expect(subject.defendants.first).to have_attributes(
          id: nil,
          full_name: 'Jake',
          maat: nil,
          position: 1,
          main: false,
        )
      end
    end

    context 'when neither defendants_attributes or defendants DB records exist' do
      it 'creates a default main defendant' do |_variable|
        expect(subject.defendants.count).to eq(1)
        expect(subject.defendants.first).to have_attributes(
          id: nil,
          full_name: nil,
          maat: nil,
          position: 1,
          main: true,
        )
      end
    end
  end

  describe '#any_marked_for_destruction' do
    let(:defendants_attributes) { { '0' => { 'full_name' => 'Jim', 'position' => '1', '_destroy' => _destroy } } }

    context 'when destroy flag is not set' do
      let(:_destroy) { nil }

      it { expect(subject).not_to be_any_marked_for_destruction }
    end

    context 'when destroy flag is set' do
      let(:_destroy) { '1' }

      it { expect(subject).to be_any_marked_for_destruction }
    end
  end

  describe '#show_destroy?' do
    context 'only one defendant' do
      let(:defendants) { [Defendant.new(full_name: 'Jake', position: '1')] }

      it { expect(subject).not_to be_show_destroy }
    end

    context 'multiple defendants' do
      let(:defendants) do
        [Defendant.new(full_name: 'Jake', position: '1'), Defendant.new(full_name: 'Jim', position: '2')]
      end

      it { expect(subject).to be_show_destroy }
    end
  end

  describe '#next_position' do
    let(:defendants) do
      [Defendant.new(full_name: 'Jake', position: '1'), Defendant.new(full_name: 'Jim', position: '20')]
    end

    it 'increaments the last position' do
      expect(subject.next_position).to eq(21)
    end
  end

  describe '#validations' do
    context 'when main defendant is invalid' do
      let(:defendants_attributes) { { '0' => { 'full_name' => 'Jim', 'maat' => nil, 'position' => '1' } } }

      it 'adds a validation error to the base object with marked as main' do
        expect(subject).not_to be_valid

        expect(form.errors.of_kind?('defendants-attributes[0].maat', :blank)).to be(true)
        expect(form.errors['defendants-attributes[0].maat']).to eq(['MAAT ID (main) cannot be blank'])
      end
    end

    context 'when additional defendant is invalid' do
      let(:defendants_attributes) do
        {
          '0' => { 'full_name' => 'Jim', 'maat' => 'AA1', 'position' => '1' },
          '1' => { 'full_name' => '', 'maat' => nil, 'position' => '1'  },
        }
      end

      it 'adds a validation error to the base object with marked as main' do
        expect(subject).not_to be_valid

        expect(form.errors.of_kind?('defendants-attributes[1].full_name', :blank)).to be(true)
        expect(form.errors.of_kind?('defendants-attributes[1].maat', :blank)).to be(true)
        expect(form.errors['defendants-attributes[1].full_name']).to eq(['Full name (additional 1) cannot be blank'])
        expect(form.errors['defendants-attributes[1].maat']).to eq(['MAAT ID (additional 1) cannot be blank'])
      end
    end
  end

  describe '#save!' do
    let(:application) { Claim.create!(office_code: 'AAA', defendants: defendants) }
    let(:defendants) { [main_defendant, additional_defendant] }
    let(:main_defendant) { Defendant.new(full_name: 'Jake', position: '1') }
    let(:additional_defendant) { Defendant.new(full_name: 'Jim', position: '2') }

    context 'when record marked as destroy' do
      let(:defendants_attributes) do
        { '0' => main_defendant.attributes, '1' => { 'id' => additional_defendant.id, '_destroy' => '1' } }
      end

      it 'will delete it' do
        expect { subject.save! }.to change { application.reload.defendants.count }.by(-1)
      end
    end
  end
end
