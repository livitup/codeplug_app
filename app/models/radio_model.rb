class RadioModel < ApplicationRecord
  # Associations
  belongs_to :manufacturer
  has_many :codeplug_layouts, dependent: :restrict_with_error

  # Serialization
  serialize :supported_modes, type: Array, coder: JSON
  serialize :frequency_ranges, type: Array, coder: JSON

  # Validations
  validates :name, presence: true
  validates :manufacturer, presence: true
  validates :supported_modes, presence: true
  validate :supported_modes_not_empty
  validates :max_zones, numericality: { greater_than: 0, allow_nil: true }
  validates :max_channels_per_zone, numericality: { greater_than: 0, allow_nil: true }
  validates :long_channel_name_length, numericality: { greater_than: 0, allow_nil: true }
  validates :short_channel_name_length, numericality: { greater_than: 0, allow_nil: true }
  validates :long_zone_name_length, numericality: { greater_than: 0, allow_nil: true }
  validates :short_zone_name_length, numericality: { greater_than: 0, allow_nil: true }

  private

  def supported_modes_not_empty
    if supported_modes.blank? || (supported_modes.is_a?(Array) && supported_modes.empty?)
      errors.add(:supported_modes, "must have at least one mode")
    end
  end
end
