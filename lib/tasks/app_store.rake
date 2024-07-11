namespace :app_store do
  desc 'Unsubscribe this branch deployment from app store notifications'

  task unsubscribe: :environment do
    AppStoreSubscriber.unsubscribe
  end
end
