Dir["#{File.join(__dir__, '../../app/attributes/type')}/*.rb"].each { |f| require f }

ActiveModel::Type.register(:string, LaaCrimeFormsCommon::Type::StrippedString)
ActiveModel::Type.register(:value_object, LaaCrimeFormsCommon::Type::ValueObject)
ActiveModel::Type.register(:multiparam_date, LaaCrimeFormsCommon::Type::MultiparamDate)
ActiveModel::Type.register(:time_period, LaaCrimeFormsCommon::Type::TimePeriod)
ActiveModel::Type.register(:gbp, LaaCrimeFormsCommon::Type::Gbp)
ActiveModel::Type.register(:fully_validatable_integer, LaaCrimeFormsCommon::Type::FullyValidatableInteger)
ActiveModel::Type.register(:fully_validatable_decimal, LaaCrimeFormsCommon::Type::FullyValidatableDecimal)
ActiveModel::Type.register(:possibly_translated_string, LaaCrimeFormsCommon::Type::PossiblyTranslatedString)
ActiveModel::Type.register(:possibly_translated_array, LaaCrimeFormsCommon::Type::PossiblyTranslatedArray)
