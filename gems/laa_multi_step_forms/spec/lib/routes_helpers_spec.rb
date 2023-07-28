require 'rails_helper'

RSpec.describe RouteHelpers, type: :routing do
  let(:id) { SecureRandom.uuid }
  let(:secondary_id) { SecureRandom.uuid }

  it 'creates show routes' do
    expect(get("/applications/#{id}/steps/start_page")).to route_to('steps/start_page#show', id:)
  end

  it 'creates edit routes' do
    expect(get("/applications/#{id}/steps/claim_type")).to route_to('steps/claim_type#edit', id:)
    expect(patch("/applications/#{id}/steps/claim_type")).to route_to('steps/claim_type#update', id:)
    expect(put("/applications/#{id}/steps/claim_type")).to route_to('steps/claim_type#update', id:)
  end

  it 'creates crud routes - minimal' do
    expect(get("/applications/#{id}/steps/defendant/#{secondary_id}")).to route_to(
      'steps/defendant#edit', id: id, defendant_id: secondary_id
    )
    expect(patch("/applications/#{id}/steps/defendant/#{secondary_id}")).to route_to(
      'steps/defendant#update', id: id, defendant_id: secondary_id
    )
    expect(put("/applications/#{id}/steps/defendant/#{secondary_id}")).to route_to(
      'steps/defendant#update', id: id, defendant_id: secondary_id
    )
  end

  it 'creates crud routes - with delete and custom' do
    expect(get("/applications/#{id}/steps/work_item/#{secondary_id}/duplicate")).to route_to(
      'steps/work_item#duplicate', id: id, work_item_id: secondary_id
    )
    expect(get("/applications/#{id}/steps/work_item/#{secondary_id}/confirm_destroy")).to route_to(
      'steps/work_item#confirm_destroy', id: id, work_item_id: secondary_id
    )
    expect(get("/applications/#{id}/steps/work_item/#{secondary_id}")).to route_to(
      'steps/work_item#edit', id: id, work_item_id: secondary_id
    )
    expect(patch("/applications/#{id}/steps/work_item/#{secondary_id}")).to route_to(
      'steps/work_item#update', id: id, work_item_id: secondary_id
    )
    expect(put("/applications/#{id}/steps/work_item/#{secondary_id}")).to route_to(
      'steps/work_item#update', id: id, work_item_id: secondary_id
    )
    expect(delete("/applications/#{id}/steps/work_item/#{secondary_id}")).to route_to(
      'steps/work_item#destroy', id: id, work_item_id: secondary_id
    )
  end

  it 'creates upload step routes' do
    expect(get("/applications/#{id}/steps/supporting_evidence")).to route_to(
      'steps/supporting_evidence#edit', id:
    )
    expect(post("/applications/#{id}/steps/supporting_evidence")).to route_to(
      'steps/supporting_evidence#create', id:
    )
    expect(patch("/applications/#{id}/steps/supporting_evidence")).to route_to(
      'steps/supporting_evidence#update', id:
    )
    expect(put("/applications/#{id}/steps/supporting_evidence")).to route_to(
      'steps/supporting_evidence#update', id:
    )
    expect(delete("/applications/#{id}/steps/supporting_evidence")).to route_to(
      'steps/supporting_evidence#destroy', id:
    )
  end
end
