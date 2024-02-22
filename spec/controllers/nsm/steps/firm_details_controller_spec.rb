require 'rails_helper'

RSpec.describe Nsm::Steps::FirmDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Nsm::Steps::FirmDetailsForm, Decisions::NsmDecisionTree
  it_behaves_like 'a step that can be drafted', Nsm::Steps::FirmDetailsForm
end
