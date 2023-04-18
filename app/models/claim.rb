class Claim < ApplicationRecord
  # TODO: confirm naming on this
  # TODO: require format and add REGEX as required
  validates :usn, presence: true,
                  uniqueness: { case_sensitive: false }
end
