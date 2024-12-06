module AppStore
  module V1
    class Collection < Array
      def initialize(elements)
        if elements.nil?
          super()
        else
          super
        end
      end

      def find(element_id)
        detect { _1.id == element_id }
      end

      def order(arg)
        order = :asc
        if arg.is_a?(Hash)
          attribute = arg.keys.first
          order = arg.values.first
        else
          attribute = arg
        end

        sorted = sort_by { _1.send(attribute) }

        return sorted unless order == :desc

        sorted.reverse
      end
    end
  end
end
