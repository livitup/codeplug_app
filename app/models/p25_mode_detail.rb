class P25ModeDetail < ApplicationRecord
  # Validations
  validates :nac, presence: true
end
