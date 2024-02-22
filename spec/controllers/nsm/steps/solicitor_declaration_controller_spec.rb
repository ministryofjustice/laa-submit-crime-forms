require 'rails_helper'

RSpec.describe Nsm::Steps::SolicitorDeclarationController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::SolicitorDeclarationForm, Decisions::NsmDecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::SolicitorDeclarationForm
end
