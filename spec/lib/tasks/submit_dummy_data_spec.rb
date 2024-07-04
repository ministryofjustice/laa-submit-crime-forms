require 'rails_helper'

describe 'submit_dummy_data:', type: :task do
  before do
    allow($stdout).to receive(:print)
  end

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
      allow($stdin).to receive(:gets).and_return 'y'
      allow(TestData::PaBuilder).to receive(:new).and_return(builder)
    end

    it 'builds the test data with defaults' do
      Rake::Task['submit_dummy_data:bulk_prior_authority'].execute
      expect(builder).to have_received(:build_many).with(bulk: 100, year: 2023)
    end

    it 'builds the test data for the specified args' do
      Rake::Task['submit_dummy_data:bulk_prior_authority'].invoke(200, 2020)
      expect(builder).to have_received(:build_many).with(bulk: 200, year: 2020)
    end
  end

  describe 'bulk_nsm' do
    let(:builder) { instance_double(TestData::NsmBuilder, build_many: true) }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow($stdin).to receive(:gets).and_return 'y'
      allow(TestData::NsmBuilder).to receive(:new).and_return(builder)
    end

    it 'builds the test data with defaults' do
      Rake::Task['submit_dummy_data:bulk_nsm'].execute
      expect(builder).to have_received(:build_many).with(bulk: 100, large: 4, year: 2023)
    end

    it 'builds the test data for the specified args' do
      Rake::Task['submit_dummy_data:bulk_nsm'].invoke(300, 30, 2020)
      expect(builder).to have_received(:build_many).with(bulk: 300, large: 30, year: 2020)
    end
  end

  describe 'prior_authority_rfi' do
    let(:resubmitter) { instance_double(TestData::PaResubmitter, resubmit: true) }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow($stdin).to receive(:gets).and_return 'y'
      allow(TestData::PaResubmitter).to receive(:new).and_return(resubmitter)
    end

    it 'passes arguments to the resubmitter' do
      Rake::Task['submit_dummy_data:prior_authority_rfi'].invoke('50')
      expect(resubmitter).to have_received(:resubmit).with(50)
    end
  end
end
