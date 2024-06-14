
namespace :reset_data do
  desc "Revert all assessed/RFI'd claims to draft and then re-submit them"
  task claims: :environment do
    Nsm::Resetter.new.call
  end
end
