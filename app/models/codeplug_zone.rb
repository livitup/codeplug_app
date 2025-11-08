class CodeplugZone < ApplicationRecord
  # Associations
  belongs_to :codeplug
  belongs_to :zone

  # Validations
  validates :codeplug, presence: true
  validates :zone, presence: true
  validates :position, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :zone_id, uniqueness: { scope: :codeplug_id }
  validates :position, uniqueness: { scope: :codeplug_id }

  # Default scope - order by position
  default_scope { order(position: :asc) }
end
