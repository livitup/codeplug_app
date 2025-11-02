class DmrModeDetail < ApplicationRecord
  # Validations
  validates :color_code, presence: true,
                         numericality: {
                           only_integer: true,
                           greater_than_or_equal_to: 0,
                           less_than_or_equal_to: 15
                         }
end
