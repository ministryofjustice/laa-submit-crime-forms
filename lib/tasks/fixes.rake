
namespace :fixes do
  namespace :multiple_primary_quotes do
    desc "Identify historic instances where a PA application could get multiple primary quotes"
    task identify: :environment do
      puts "Application IDs where there are multiple primary quotes. " \
           "These will need to be made provider-editable in the app store before they can be fixed, " \
           "and then moved back to their original state after they are fixed"
      puts Fixes::MultiplePrimaryQuoteFixer.new.identify
    end

    desc "Fix historic instances where a PA application could get multiple primary quotes"
    task fix: :environment do
      Fixes::MultiplePrimaryQuoteFixer.new.fix
    end
  end

  desc "Find mismatched LAA references for sent back CRM4 applications"
  task find_mismatched_references: :environment do
    sent_back_submissions = PriorAuthorityApplication.where(state: "sent_back")
    sent_back_submissions.each do |submission|
      app_store_data = AppStoreClient.new.get(submission.id)
      app_store_reference = app_store_data['application']['laa_reference']
      if submission.laa_reference != app_store_reference
        puts "Submission ID: #{submission.id} App Store Reference: #{app_store_reference} Provider Reference: #{submission.laa_reference}"
      end
    end
  end

  desc "Amend a contact email address. Typically because user has added a valid but undeliverable address"
  task :update_contact_email, [:id, :new_contact_email] => :environment do |_, args|
    submission = PriorAuthorityApplication.find_by(id: args[:id]) || Claim.find_by(id: args[:id])

    STDOUT.print "This will update #{submission.class} #{submission.laa_reference}'s contact email, \"#{submission.solicitor.contact_email || 'nil'}\", to \"#{args[:new_contact_email]}\": Are you sure? (y/n): "
    input = STDIN.gets.strip

    if input.downcase.in?(['yes','y'])
      print 'updating...'
      submission.solicitor.contact_email = args[:new_contact_email]
      submission.solicitor.save!(touch: false)
      submission.reload.solicitor.reload
      puts "#{submission.laa_reference}'s contact email is now #{submission.solicitor.contact_email}"
    end
  end
end
