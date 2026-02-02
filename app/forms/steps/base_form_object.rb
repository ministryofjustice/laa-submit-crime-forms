module Steps
  class BaseFormObject
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment
    include LaaCrimeFormsCommon::Validators

    attr_accessor :application,
                  :record

    # Initialize a new form object given an AR model, reading and setting
    # the attributes declared in the form object.
    # Most of the times, `record` is just the main DB table, but sometimes,
    # for example in has_one or has_many, `record` is a different table.
    def self.build(record, application: nil)
      unless record.is_a?(ApplicationRecord) || record.is_a?(AppStore::V1::Base)
        raise ArgumentError, "expected `ApplicationRecord`, got `#{record.class}`"
      end

      attrs = record.slice(
        attribute_names & record.attribute_names
      ).merge!(
        application: application || record,
        record: record
      )

      new(attrs)
    end

    def save
      valid? && persist!
    end

    # This is a `save if you can, but it's fine if not` method, bypassing validations
    def save!
      persist!
    rescue StandardError
      false
    end

    # Intended to quickly verify if form attribute values have changed
    # compared to those in the persisted DB record. This will mostly work
    # for simple hashes { attr: value }, but complex structures will require
    # their custom, more in-deep change method, overriding this one.
    def changed?
      !record.slice(*attribute_names).eql?(attributes)
    end

    def attribute_changed?(attribute)
      self[attribute] != record.public_send(attribute)
    end

    def to_key
      # Intentionally returns nil so the form builder picks up only
      # the class name to generate the HTML attributes
      nil
    end

    def persisted?
      false
    end

    def new_record?
      true
    end

    # Add the ability to read/write attributes without calling their accessor methods.
    # Needed to behave more like an ActiveRecord model, where you can manipulate the
    # DB attributes making use of `self[:attribute]`
    def [](attr_name)
      public_send(attr_name)
    end

    def []=(attr_name, value)
      public_send(:"#{attr_name}=", value)
    end

    private

    def validate_time_period_max_hours(attribute, max_hours:)
      value = public_send(attribute)
      # :nocov:
      return if value.blank? || value.is_a?(Hash)
      return unless value.respond_to?(:hours)
      # :nocov:

      errors.add(attribute, :max_hours, count: max_hours) if value.hours.to_i > max_hours
    end

    # :nocov:
    def persist!
      raise 'Subclasses of BaseFormObject need to implement #persist!'
    end
    # :nocov:
  end
end
