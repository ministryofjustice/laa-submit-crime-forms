module Decisions
  class OrderedSteps
    def self.nsm_after(step)
      nsm_steps = new.nsm.map(&:to_s)
      nsm_steps[(nsm_steps.index(step) + 1)..]
    end

    def nsm
      # There are some steps in NSM that are not linked directly from other steps. You can only get to them
      # by clicking a link on the start page, or clicking the new claim button. Therefore we have
      # to hard-code these here in order, as the decision tree doesn't know how to get there
      %i[details boi_details firm_details other_info equality
         nsm_further_information].each_with_object([]) do |step, previous_steps|
        build_chain(step, previous_steps:)
      end
    end

    # This is a recursive method designed to take the simplified version of the decision tree
    # created below and use it to work out the order of steps, i.e. flatten the tree into a
    # chain. It doesn't try to work out the specific steps used in a given submission, but
    # instead tries to work out the relative order of all possible steps in a given namespace
    def build_chain(step_name, previous_steps: [], stop_steps: previous_steps + [:check_answers])
      ret = previous_steps

      # the tree has `check_answers` keyed on `nsm_check_answers` to distinguish it from PA
      step_name_for_chain = step_name.to_s.gsub('nsm_', '').to_sym
      ret << step_name_for_chain
      return ret if stop_steps.include?(step_name_for_chain)

      next_steps = simple_tree[step_name]
      next_steps&.each do |next_step|
        onwards_chain = build_chain(next_step, stop_steps: stop_steps + ret)
        if ret.include?(onwards_chain.last)
          ret.insert(ret.index(onwards_chain.last), *onwards_chain.reject { ret.include?(_1) })
        else
          onwards_chain.each { ret << _1 unless ret.include?(_1) }
        end
      end

      ret
    end

    # This takes the decision tree and reduces it down to a bunch of to->from pairs,
    # where "to" is a symbol representing a step, and "from" is an array of symbols
    # representing steps that could follow the to symbol
    def simple_tree
      @simple_tree ||= Decisions::DecisionTree.rules.transform_values do |rule|
        rule.destinations.map do |condition_destination_pair|
          action_step_pair_or_proc = condition_destination_pair[1]
          if action_step_pair_or_proc.is_a?(Proc)
            # This is the special `overwrite_to_cya` proc, which may or may not specify some
            # new destination
            extract_next_step_from_cya_proc(action_step_pair_or_proc)
          else
            action_step_pair = action_step_pair_or_proc
            namespaced_step_string = action_step_pair.values.first
            namespaced_step_string.split('/').last.to_sym
          end
        end
      end
    end

    def extract_next_step_from_cya_proc(cya_proc)
      tester = Tester.new
      tester.instance_exec(&cya_proc)
      if tester.destination
        tester.destination.split('/').last.to_sym
      else
        :start_page
      end
    end

    class Tester
      def overwrite_to_cya(options = {})
        @destination = options[:destination]
      end

      attr_reader :destination
    end
  end
end
