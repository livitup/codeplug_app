class Codeplug < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :channels, dependent: :destroy
  has_many :codeplug_zones, dependent: :destroy
  has_many :zones, through: :codeplug_zones

  # Validations
  validates :name, presence: true
end
