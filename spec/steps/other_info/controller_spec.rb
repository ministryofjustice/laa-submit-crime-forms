require 'rails_helper'

RSpec.describe Steps::OtherInfoController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::OtherInfoForm, Decisions::SimpleDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::OtherInfoForm
end
