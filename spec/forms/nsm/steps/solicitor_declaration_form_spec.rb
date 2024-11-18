require 'rails_helper'

RSpec.describe Nsm::Steps::SolicitorDeclarationForm do
  let(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      application:,
      signatory_name:,
    }
  end

  let(:application) { create(:claim, :complete, state: 'draft') }

  describe '#save the form' do
    let(:job) { instance_double(SubmitToAppStore) }

    before do
      allow(SubmitToAppStore).to receive(:new).and_return(job)
      allow(job).to receive(:perform)
      allow(application).to receive(:update!).and_return(true)
    end

    context 'when all fields are set' do
      let(:signatory_name) { 'John Doe' }

      it 'is valid' do
        expect(form.save).to be_truthy
        expect(application.state).to eq('submitted')
        expect(application).to have_received(:update!)
      end

      it 'notifies the app store' do
        form.save

        expect(job).to have_received(:perform).with(submission: application)
      end

      it 'updates submission to correct state' do
        form.save

        expect(application.state).to eq('submitted')
      end
    end

    context 'when rfi is available for pa and nsm' do
      let(:signatory_name) { 'John Doe' }
      let(:application) { create(:claim, :complete, :with_further_information_supplied, state: 'sent_back') }

      before do
        allow(application.pending_further_information).to receive(:update!).and_return(true)
      end

      it 'notifies the app store' do
        form.save

        expect(job).to have_received(:perform).with(submission: application)
      end

      it 'updates submission to correct state' do
        form.save

        expect(application.state).to eq('provider_updated')
      end
    end

    context 'when claim is in incorrect state' do
      let(:signatory_name) { 'John Doe' }
      let(:application) { create(:claim, :complete, state: 'submitted') }

      before do
        allow(application).to receive(:update!).and_return(true)
      end

      it 'returns an error' do
        expect { form.save }.to raise_error('Invalid state for claim submission')
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

    ['Jim Bob', "J'm Bob", "Jim B'b", 'J-m Bob', 'Jim B-b', 'Jim Bob Bob', 'Jim B.b', 'Jim B,b'].each do |name|
      context "it is a valid name string: #{name}" do
        let(:signatory_name) { name }

        it { expect(form).to be_valid }
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

    ['Jim Bob!', 'Jim', 'Jim-Bob', 'jim@bob', 'jim the 1st'].each do |name|
      context "it is a invalid name string: #{name}" do
        let(:signatory_name) { name }

        it 'is invalid' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:signatory_name, :invalid)).to be(true)
        end
      end
    end
  end
end
