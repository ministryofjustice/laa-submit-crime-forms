module AppStore
  module V1
    module Nsm
      class LetterOrCall < AppStore::V1::Base
        attribute :type, :possibly_translated_string
        adjustable_attribute :count, :integer
        adjustable_attribute :uplift, :integer
        attribute :adjustment_comment, :string
      end
    end
  end
end
