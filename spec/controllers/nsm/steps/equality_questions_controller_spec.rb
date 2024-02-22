require 'rails_helper'

RSpec.describe Nsm::Steps::EqualityQuestionsController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::EqualityQuestionsForm, Decisions::NsmDecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::EqualityQuestionsForm
end
