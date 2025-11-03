class ChannelZone < ApplicationRecord
  # Associations
  belongs_to :channel
  belongs_to :zone

  # Validations
  validates :position, presence: true
  validates :position, numericality: { only_integer: true, greater_than: 0 }
  validates :position, uniqueness: { scope: :zone_id }
end
