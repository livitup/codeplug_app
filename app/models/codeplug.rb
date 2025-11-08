class Codeplug < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :zones, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :codeplug_zones, dependent: :destroy

  # Validations
  validates :name, presence: true
end
