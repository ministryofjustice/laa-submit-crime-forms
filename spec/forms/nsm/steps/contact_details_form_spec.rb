require 'rails_helper'

RSpec.describe Nsm::Steps::ContactDetailsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      contact_first_name:,
      contact_last_name:,
      contact_email:,
      application:,
    }
  end

  let(:application) { create(:claim, solicitor:) }
  let(:solicitor) { create(:solicitor) }

  let(:contact_first_name) { 'Jim' }
  let(:contact_last_name) { 'Bob' }
  let(:contact_email) { 'job@bob.com' }

  describe '#valid?' do
    context 'when all fields are set' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    %i[contact_first_name contact_last_name contact_email].each do |field|
      context "when #{field} is missing" do
        let(field) { nil }

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(field, :blank)).to be(true)
        end
      end
    end

    context 'when email is invalid' do
      let(:contact_email) { 'foo@bar@mar' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_email, :invalid)).to be(true)
      end
    end

    context 'when email is invalid in a way the default regex does not capture' do
      let(:contact_email) { 'foo@barmar' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_email, :invalid)).to be(true)
      end
    end
  end

  describe 'save!' do
    before { form.save! }

    context 'when details have not previously been set' do
      it 'sets them' do
        expect(solicitor.reload).to have_attributes(
          contact_first_name:,
          contact_last_name:,
          contact_email:,
        )
      end
    end

    context 'when details are unchanged' do
      let(:solicitor) do
        create(:solicitor,
               contact_first_name:,
               contact_last_name:,
               contact_email:)
      end

      it 'does not create a new object' do
        expect(solicitor.reload).to have_attributes(
          contact_first_name:,
          contact_last_name:,
          contact_email:,
        )

        expect(application.reload.solicitor).to eq solicitor
      end
    end
  end
end
