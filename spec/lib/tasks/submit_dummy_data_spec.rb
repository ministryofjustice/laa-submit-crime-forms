require 'rails_helper'

describe 'submit_dummy_data:', type: :task do
  describe 'prior_authority' do
    let(:dummy_client) { instance_double(AppStoreClient) }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow(AppStoreClient).to receive(:new).and_return(dummy_client)
      allow(dummy_client).to receive(:post)
    end

    it 'makes an HTTP request' do
      Rake::Task['submit_dummy_data:prior_authority'].invoke
      expect(AppStoreClient).to have_received(:new)
      expect(dummy_client).to have_received(:post)
    end
  end

  describe 'bulk_prior_authority' do
    let(:builder) { instance_double(TestData::PaBuilder, build_many: true) }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow(TestData::PaBuilder).to receive(:new).and_return(builder)
    end

    it 'builds the test data' do
      Rake::Task['submit_dummy_data:bulk_prior_authority'].execute
      expect(builder).to have_received(:build_many).with(bulk: 100_000, year: 2023)
    end

    context 'when year is set' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('YEAR', 2023).and_return('2020')
      end

      it 'builds the test data for the specified YEAR' do
        Rake::Task['submit_dummy_data:bulk_prior_authority'].execute
        expect(builder).to have_received(:build_many).with(bulk: 100_000, year: 2020)
      end
    end
  end

  describe 'bulk_nsm' do
    let(:builder) { instance_double(TestData::NsmBuilder, build_many: true) }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow(TestData::NsmBuilder).to receive(:new).and_return(builder)
    end

    it 'builds the test data' do
      Rake::Task['submit_dummy_data:bulk_nsm'].execute
      expect(builder).to have_received(:build_many).with(bulk: 24_000, large: 20, year: 2023)
    end

    context 'when year is set' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('YEAR', 2023).and_return('2020')
      end

      it 'builds the test data for the specified YEAR' do
        Rake::Task['submit_dummy_data:bulk_nsm'].execute
        expect(builder).to have_received(:build_many).with(bulk: 24_000, large: 20, year: 2020)
      end
    end
  end
end
