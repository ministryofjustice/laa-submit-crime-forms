module Steps
  module HasOneAssociation
    extend ActiveSupport::Concern

    class_methods do
      attr_accessor :association_name, :through_association

      def build(application)
        super(
          associated_record(application), application:
        )
      end

      # Return the record if already exists, or initialise a blank one
      def associated_record(application)
        parent = if through_association
                   # :nocov: enable coverage once we use this in any form
                   existing_or_build(application, through_association)
                   # :nocov:
                 else
                   application
                 end

        existing_or_build(parent, association_name)
      end

      def existing_or_build(parent, name)
        parent.public_send(name) || parent.public_send(:"build_#{name}")
      end

      def has_one_association(name, through: nil)
        self.association_name = name
        self.through_association = through

        safe_name = name == :case ? "_#{name}" : name
        define_method(safe_name) do
          @_assoc ||= self.class.associated_record(application)
        end
      end
    end
  end
end
