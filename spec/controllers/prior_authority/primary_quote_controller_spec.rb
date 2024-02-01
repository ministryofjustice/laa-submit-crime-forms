require 'rails_helper'

RSpec.describe PriorAuthority::Steps::PrimaryQuoteController, type: :controller do
  let(:application) { build(:prior_authority_application, primary_quote: quote) }
  let(:quote) { build(:quote, :primary) }

  before do
    allow(controller).to receive(:current_application).and_return(application)
  end

  describe '#primary_quote' do
    context 'non custom primary quote service' do
      it 'returns a quote with non custom service type' do
        expect(subject.send(:primary_quote)).to eq(quote)
      end
    end

    context 'custom primary quote service' do
      let(:quote) { build(:quote, :primary, :custom) }

      it 'returns a quote with non custom service type' do
        expect(subject.send(:primary_quote).service_type).to eq('random service')
      end
    end
  end
end
