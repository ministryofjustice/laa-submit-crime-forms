module Type
  class PossiblyTranslatedString < ActiveModel::Type::String
    # This is for attributes that will either be of format "x"
    # or of format { "en" => "Some string", "value" => "x" }
    def cast(value)
      value.is_a?(Hash) ? super(value['value']) : super
    end
  end
end
