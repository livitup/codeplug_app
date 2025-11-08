class Zone < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :codeplug, optional: true
  has_many :channel_zones, dependent: :destroy
  has_many :channels, through: :channel_zones
  has_many :zone_systems, dependent: :destroy
  has_many :systems, through: :zone_systems

  # Validations
  validates :name, presence: true
  validates :user, presence: true

  # Scopes
  scope :publicly_visible, -> { where(public: true) }
  scope :owned_by, ->(user) { where(user: user) }
end
