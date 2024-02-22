module Decisions
  class DslDecisionTree < BaseDecisionTree
    WRAPPER_CLASS = SimpleDelegator

    class << self
      def rules
        @rules ||= {}
      end

      def from(source)
        raise "Rule already exists for #{source}" if rules[source]

        rules[source] = Rule.new
      end
    end

    attr_reader :destinations, :session

    def initialize(*, **)
      super
      @destinations = Array(self.class.rules[step_name]&.destinations)
    end

    def destination
      return to_route(index: '/nsm/claims') if destinations.none?

      detected = nil
      _, destination = destinations.detect do |(condition, _)|
        detected = condition.nil? || wrapped_form_object.instance_exec(&condition.to_proc)
      end

      return to_route(index: '/nsm/claims') unless destination

      to_route(resolve_procs(destination, detected))
    end

    def wrapped_form_object
      self.class::WRAPPER_CLASS.new(form_object)
    end

    def resolve_procs(hash_or_proc, detected)
      hash = resolve_proc(hash_or_proc, detected)
      hash.transform_values { |value| resolve_proc(value, detected) }
    end

    def resolve_proc(value, detected)
      if value.respond_to?(:call)
        value.arity.zero? ? wrapped_form_object.instance_exec(&value) : value.call(detected)
      else
        value
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
