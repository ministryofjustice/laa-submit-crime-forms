
namespace :fixes do
  desc "Amend a contact email address. Typically because user has added a valid but undeliverable address"
  task :update_contact_email, [:id, :new_contact_email] => :environment do |_, args|
    submission = PriorAuthorityApplication.find_by(id: args[:id]) || Claim.find_by(id: args[:id])

    STDOUT.print "This will update #{submission.class} #{submission.id}'s contact email, \"#{submission.solicitor.contact_email || 'nil'}\", to \"#{args[:new_contact_email]}\": Are you sure? (y/n): "
    input = STDIN.gets.strip

    if input.downcase.in?(['yes','y'])
      print 'updating...'
      submission.solicitor.contact_email = args[:new_contact_email]
      submission.solicitor.save!(touch: false)
      submission.reload.solicitor.reload
      puts "#{submission.id}'s contact email is now #{submission.solicitor.contact_email}"
    end
  end
end
