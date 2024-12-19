module Cloneable
  include GeneratesLaaReference

  def clone_application
    current_application.deep_dup.tap do |new_application|
      new_application.laa_reference = generate_laa_reference
    end
  end
end
