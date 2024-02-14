Dir["#{File.join(__dir__, '../../app/attributes/type')}/*.rb"].each { |f| require f }

ActiveModel::Type.register(:string, Type::StrippedString)
ActiveModel::Type.register(:value_object, Type::ValueObject)
ActiveModel::Type.register(:multiparam_date, Type::MultiparamDate)
ActiveModel::Type.register(:time_period, Type::TimePeriod)
ActiveModel::Type.register(:gbp, Type::Gbp)
ActiveModel::Type.register(:fully_validatable_integer, Type::FullyValidatableInteger)
