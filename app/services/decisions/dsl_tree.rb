module Decisions
  class DslTree < BaseDecisionTree
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

    def destination
      rule = self.class.rules[step_name]

      return to_route(index: '/claims') unless rule

      detected = nil
      _, destination = rule.destinations.detect do |(condition, _)|
        detected = condition.nil? || wrapped_form_object.instance_exec(&condition.to_proc)
      end

      return to_route(index: '/claims') unless destination

      processed_hash = destination.transform_values do |value|
        if value.respond_to?(:call)
          value.arity.zero? ? wrapped_form_object.instance_exec(&value) : value.call(detected)
        else
          value
        end
      end

      to_route(processed_hash)
    end

    def wrapped_form_object
      self.class::WRAPPER_CLASS.new(form_object)
    end

    def to_route(hash)
      if hash[:edit]
        { controller: hash.delete(:edit), action: :edit, id: application }.merge(hash)
      elsif hash[:show]
        { controller: hash.delete(:show), action: :show, id: application }.merge(hash)
      elsif hash[:index]
        { controller: hash.delete(:index), action: :index }.merge(hash)
      else
        raise 'Invalid hash'
      end
    end
  end
end
