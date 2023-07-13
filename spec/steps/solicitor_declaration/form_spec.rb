require 'rails_helper'

RSpec.describe Steps::SolicitorDeclarationForm do
  let(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      application:,
      signatory_name:,
    }
  end

  let(:application) { instance_double(Claim, update!: true, 'status=': true) }

  describe '#save the form' do
    context 'when all fields are set' do
      let(:signatory_name) { 'John Doe' }

      it 'is valid' do
        expect(form.save).to be_truthy
        expect(application).to have_received(:status=).with('completed')
        expect(application).to have_received(:update!)
        expect(form).to be_valid
      end
    end
  end

  describe 'form is #valid' do
    context 'when the field is set' do
      let(:signatory_name) { 'John Doe' }

      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end

  describe 'form is #invalid' do
    context 'when the field is empty' do
      let(:signatory_name) { nil }

      it 'is invalid' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:signatory_name, :blank)).to be(true)
      end
    end
  end
end
