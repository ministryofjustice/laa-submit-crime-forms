# https://dsdmoj.atlassian.net/browse/CRM457-2208

namespace :CRM457_2208 do
  desc "fix primary quotes base cost allowed totals to show correct adjusted amounts for part_grants where service_type is custom"
  task fix: :environment do
    PriorAuthorityApplication.joins(:primary_quote).where(state: :part_grant, service_type: :custom, quotes: { user_chosen_cost_type: :per_item }).find_each do |paa|
      puts "===before===="
      puts "pa_id: #{paa.id} primary_quote_allowed_total: #{paa.primary_quote.base_cost_allowed}"
      record = AppStoreClient.new.get(paa.id)
      PriorAuthority::AssessmentSyncer.call(paa, record:)
      puts "===after====="
      puts "pa_id: #{paa.id} primary_quote_allowed_total: #{paa.primary_quote.base_cost_allowed}"
    end
  end
end
