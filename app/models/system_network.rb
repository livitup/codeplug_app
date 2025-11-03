class SystemNetwork < ApplicationRecord
  # Associations
  belongs_to :system
  belongs_to :network

  # Validations
  validates :system_id, uniqueness: { scope: :network_id }
end
