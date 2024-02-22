require 'rails_helper'

RSpec.describe Nsm::Steps::LettersCallsController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::LettersCallsForm, Decisions::NsmDecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::LettersCallsForm
end
