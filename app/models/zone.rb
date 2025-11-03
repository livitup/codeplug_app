class Zone < ApplicationRecord
  # Associations
  belongs_to :codeplug
  has_many :channel_zones, dependent: :destroy
  has_many :channels, through: :channel_zones

  # Validations
  validates :name, presence: true
end
