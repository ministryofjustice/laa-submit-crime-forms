module GeneratesLaaReference
  def generate_laa_reference
    ActiveRecord::Base.transaction do
      self.class.model_class.lock
      loop do
        random_reference = "LAA-#{SecureRandom.alphanumeric(6)}"
        break random_reference unless self.class.model_class.exists?(laa_reference: random_reference)
      end
    end
  end
end
