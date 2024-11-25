module AppStore
  module V1
    # This class forms the basis of a series of models that behave a bit like ActiveRecord objects.
    # They are useful in that they can be passed to presenter and form objects that expect ActiveRecord
    # objects without breaking.

    # Fundamentally they are ActiveModel objects with attributes, designed to be instantiated by
    # passing in a payload from the app store, with a couple of nice features to facilitate that.

    # First, we can mimic belongs_to and has_many relationships using the `one` and `many` macros. These
    # automatically define and instantiate related objects based on the app store payload.

    # Second, for fields that could have been overwritten by a caseworker adjustment, we can define them
    # as an `adjustable_attribute` rather than an `attribute`. This automagically handles the weirdness
    # whereby the adjusted value will be listed under the original attribute name, while the original
    # attribute will be shifted to a `x_original` attribute. In the provider app we assume our objects
    # have the claimed attribute under the original attribute name, and we want to put the assessed
    # attribute separately, so we have to swap these fields around
    class Base
      include ActiveModel::Model
      include ActiveModel::Attributes

      def initialize(app_store_record, parent = nil)
        @app_store_record = transform_adjustable_attributes(app_store_record)
        @parent = parent

        super(@app_store_record.slice(*self.class.attribute_names))
      end

      attr_reader :parent

      def [](attribute)
        send(attribute)
      end

      # The problem we face is that _if_ an adjustable value has been adjusted, the
      # payload will have replaced the original value, and moved the original value
      # into an `_original` attribute. But we want the original value to be in the original
      # place, so we have to swap things back
      def transform_adjustable_attributes(app_store_record)
        return app_store_record if self.class.adjustable_attribute_names.blank?

        untouched = app_store_record.except(self.class.adjustable_attribute_names.map(&:to_s))
        adjustables = self.class.adjustable_attribute_names.map do |name|
          original_value = app_store_record.fetch("#{name}_original", app_store_record[name.to_s])
          allowed_value = app_store_record[name.to_s]
          { name.to_s => original_value, "assessed_#{name}" => allowed_value }
        end

        untouched.merge(adjustables.reduce(&:merge))
      end

      class << self
        attr_reader :adjustable_attribute_names

        def adjustable_attribute(attribute_name, type, options = {})
          @adjustable_attribute_names ||= []
          @adjustable_attribute_names << attribute_name
          attribute attribute_name, type, **options
          attribute :"assessed_#{attribute_name}", type, **options
        end

        def many(name, klass, key: name, collection_class: Collection)
          variable_symbol = :"@#{name}"
          define_method(name) do
            unless instance_variable_defined?(variable_symbol)
              models = instance_variable_get(:@app_store_record)[key.to_s]&.map { klass.new(_1, self) }
              instance_variable_set(variable_symbol, collection_class.new(models))
            end

            instance_variable_get(variable_symbol)
          end
        end

        def one(name, klass)
          variable_symbol = :"@#{name}"
          define_method(name) do
            unless instance_variable_defined?(variable_symbol)
              data = instance_variable_get(:@app_store_record)[name.to_s]
              model = klass.new(data, self) if data
              instance_variable_set(variable_symbol, model)
            end

            instance_variable_get(variable_symbol)
          end
        end
      end

      def method_missing(name, *)
        if name.ends_with?('?') && respond_to?(name)
          send(name[..-2], *)
        # :nocov:
        else
          super
          # :nocov:
        end
      end

      def respond_to_missing?(name, _include_private = false)
        (name.ends_with?('?') && respond_to?(name[..-2])) || super
      end
    end
  end
end
