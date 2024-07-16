
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
end
