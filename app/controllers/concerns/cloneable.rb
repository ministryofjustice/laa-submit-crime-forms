module Cloneable
  include GeneratesLaaReference

  def clone_application
    current_application.deep_dup
  end
end
