module Decisions
  class DslDecisionTree < BaseDecisionTree
    WRAPPER_CLASS = SimpleDelegator
    ANY = '*'.freeze

    class << self
      def rules
        @rules ||= {}
      end

      def from(source)
        raise "Rule already exists for #{source}" if rules[source]

        rules[source] = Rule.new
      end
    end

    attr_reader :destinations, :any_destinations

    def initialize(*, **)
      super
      @any_destinations = Array(self.class.rules[ANY]&.destinations)
      @destinations = Array(self.class.rules[step_name]&.destinations)
    end

    def destination
      return to_route(index: '/nsm/claims') if destinations.none?

      destination, detected = process
      any_destination, any_detected = process(any_destinations)

      destination = any_destination || destination
      detected = any_detected || detected

      return to_route(index: '/nsm/claims') unless destination

      to_route(process_hash(destination, detected))
    end

    def process(paths = destinations)
      detected = nil
      _, destination = paths.detect do |(condition, _)|
        detected =
          if condition.nil?
            true
          else
            args = condition.arity.zero? ? [] : [self]
            wrapped_form_object.instance_exec(*args, &condition.to_proc)
          end
      end

      [destination, detected]
    end

    def wrapped_form_object
      self.class::WRAPPER_CLASS.new(form_object)
    end

    def process_hash(hash, detected)
      hash.transform_values do |value|
        if value.respond_to?(:call)
          value.arity.zero? ? wrapped_form_object.instance_exec(&value) : value.call(detected)
        else
          value
        end
      end
    end

    def to_route(hash)
      if hash[:edit]
        { controller: hash.delete(:edit), action: :edit }.merge(hash)
      elsif hash[:show]
        { controller: hash.delete(:show), action: :show }.merge(hash)
      elsif hash[:index]
        { controller: hash.delete(:index), action: :index }.merge(hash)
      elsif hash[:new]
        { controller: hash.delete(:new), action: :new }.merge(hash)
      else
        raise "No known verbs found in #{hash.inspect}"
      end
    end
  end
end
