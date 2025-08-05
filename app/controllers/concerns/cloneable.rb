module Cloneable

  def clone_application
    current_application.deep_dup
  end
end
