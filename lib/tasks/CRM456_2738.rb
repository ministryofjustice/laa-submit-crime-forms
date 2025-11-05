# https://dsdmoj.atlassian.net/browse/CRM457-2738

namespace :CRM457_2738 do
  desc "Reset all draft claims to have nil for supplemental claim flag"
  task :reset_supplemental_claims: :environment do
    draft_claims = Claim.where(status: "draft")
    print "#{draft_claims.count} claims identified"
    counter = 0
    draft_claims.each do |claim|
      claim.update!(supplemental_claim: nil)
      counter += 1
    end
    print "#{counter} claims reset"
  end
end
