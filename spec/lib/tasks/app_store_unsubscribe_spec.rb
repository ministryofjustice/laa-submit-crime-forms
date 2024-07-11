require 'rails_helper'

describe 'app_store:', type: :task do
  describe 'unsubscribe' do
    subject { Rake::Task['app_store:unsubscribe'] }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow(AppStoreSubscriber).to receive(:unsubscribe)
    end

    after do
      Rake::Task['app_store:unsubscribe']
    end

    it 'calls the service' do
      subject.invoke
      expect(AppStoreSubscriber).to have_received(:unsubscribe)
    end
  end
end
