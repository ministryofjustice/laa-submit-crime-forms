FactoryBot.define do
  factory :additional_cost do
    name { 'Joe Bloggs' }
    description { 'LAA' }
    unit_type { 'per_item' }
    cost_per_hour { nil }
    cost_per_item { 12.0 }
    period { nil }
    items { 10 }
  end
end
