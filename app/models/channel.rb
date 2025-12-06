class Channel < ApplicationRecord
  # Constants for enums
  TONE_MODES = [ "none", "tx_only", "rx_only", "tx_rx" ].freeze
  TRANSMIT_PERMISSIONS = [ "allow", "forbid_tx" ].freeze
  BANDWIDTHS = [ "12.5 kHz", "20 kHz", "25 kHz" ].freeze

  # Associations
  belongs_to :codeplug
  belongs_to :system
  belongs_to :system_talk_group, optional: true
  has_many :channel_zones, dependent: :destroy
  has_many :zones, through: :channel_zones

  # Validations
  validates :name, presence: true
  validates :tone_mode, inclusion: { in: TONE_MODES, message: "'%{value}' is not a valid tone_mode" }
  validates :transmit_permission, inclusion: { in: TRANSMIT_PERMISSIONS, message: "'%{value}' is not a valid transmit_permission" }
end
