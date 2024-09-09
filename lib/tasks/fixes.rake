
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

  namespace :mismatched_references do
    desc "Find mismatched LAA references for sent back CRM4 applications"
    task find: :environment do
      sent_back_submissions = PriorAuthorityApplication.where(state: "sent_back")
      sent_back_submissions.each do |submission|
        app_store_data = AppStoreClient.new.get(submission.id)
        app_store_reference = app_store_data['application']['laa_reference']
        if submission.laa_reference != app_store_reference
          puts "Submission ID: #{submission.id} App Store Reference: #{app_store_reference} Provider Reference: #{submission.laa_reference}"
        end
      end
    rescue StandardError => e
      puts "Error fetching details"
      puts e
    end

    desc "Fix mismatched LAA references for sent back CRM4 applications"
    task fix: :environment do
      # retrieved by running mismatched_references:find rake task 9-09-2024 13:00
      records = [
          {submission_id: '8db79c28-35fd-42ae-aef8-156fbe28631a', laa_reference: 'LAA-Xcoqqz'}
        ]

      records.each do |record|
        id = record['submission_id']
        new_reference = record['laa_reference']
        fix_laa_reference(id, new_reference)
      end
    end

    def fix_laa_reference(id, new_reference)
      submission = PriorAuthorityApplication.find(id)
      if submission
        old_reference = submission.laa_reference

        submission.laa_reference = new_reference
        submission.save!(touch: false)
        puts "Fixed LAA Reference for Submission: #{id}. Old Reference: #{old_reference}, New Reference: #{new_reference}"
      else
        puts "Could not find Submission: #{id}"
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
