require 'rails_helper'

RSpec.describe Steps::WorkItemsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::AddAnotherForm, Decisions::SimpleDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::AddAnotherForm
end
