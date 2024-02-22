require 'rails_helper'

RSpec.describe Nsm::Steps::OtherInfoController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::OtherInfoForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::OtherInfoForm
end
