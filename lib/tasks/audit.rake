
namespace :audit do
  desc "Generate audit of all activity associated with office codes since a given date"
  # Usage: bx rails audit:office_codes[AAAAA|BBBBB,2024-06-01]
  # Or if you're using zsh: bx rails audit:office_codes\[AAAAA|BBBBB,2024-06-01\]
  task :office_codes, [:codes, :since] => :environment do |_, args|
    office_codes = args.codes.split('|')
    since = Date.parse(args.since)

    $stdout.puts Auditor.new(office_codes, since).call
  end
end
