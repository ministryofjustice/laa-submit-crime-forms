# frozen_string_literal: true

class UpdateVirusDefinitions < ApplicationJob
  def perform
    Clamby.update
  end
end
