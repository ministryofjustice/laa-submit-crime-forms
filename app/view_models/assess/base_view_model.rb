module Assess
  class BaseViewModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    ID_FIELDS = ['id'].freeze

    class Builder
      attr_reader :klass, :claim, :rows, :return_array

      def initialize(class_type, claim, *nesting)
        @klass = "Assess::V#{claim.json_schema_version}::#{class_type.to_s.camelcase}".constantize
        @claim = claim
        if nesting.any?
          @rows = claim.data.dig(*nesting)
          @return_array = true
        else
          @rows = [claim.data]
          @return_array = false
        end
      end

      def build
        process do |attributes|
          instance = klass.new(params(attributes))

          if adjustments?
            key = [klass::LINKED_TYPE, instance.id]
            instance.adjustments = all_adjustments.fetch(key, [])
          end

          instance
        end
      end

      private

      def params(attributes)
        claim.attributes
             .merge(attributes, 'claim' => claim)
             .slice(*klass.attribute_names)
      end

      def process(&block)
        result = rows.map(&block)
        return_array ? result : result[0]
      end

      def all_adjustments
        @all_adjustments ||=
          claim.events
               .where(linked_type: klass::LINKED_TYPE)
               .order(:created_at)
               .group_by { |event| [event.linked_type, event.linked_id] }
      end

      def adjustments?
        klass.const_defined?(:LINKED_TYPE)
      end
    end

    class << self
      def build(class_type, claim, *)
        Builder.new(class_type, claim, *).build
      end
    end

    def [](val)
      public_send(val)
    end
  end
end
