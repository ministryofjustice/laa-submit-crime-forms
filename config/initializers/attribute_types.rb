Dir["#{File.join(__dir__, '../../app/attributes/type')}/*.rb"].each { |f| require f }

ActiveModel::Type.register(:translated, Type::TranslatedObject)
ActiveModel::Type.register(:time_period, Type::TimePeriod)
