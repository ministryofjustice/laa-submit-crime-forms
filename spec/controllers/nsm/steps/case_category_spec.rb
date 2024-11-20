require 'rails_helper'

RSpec.describe Nsm::Steps::CaseCategoryController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::CaseCategoryForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::CaseCategoryForm
end
