class System < ApplicationRecord
  # Constants
  MODES = [ "analog", "dmr", "p25", "nxdn" ].freeze

  # Associations
  belongs_to :mode_detail, polymorphic: true

  # TODO: Uncomment when SystemNetwork join model is implemented
  # has_many :system_networks, dependent: :destroy
  # has_many :networks, through: :system_networks

  # TODO: Uncomment when SystemTalkGroup join model is implemented
  # has_many :system_talk_groups, dependent: :destroy
  # has_many :talk_groups, through: :system_talk_groups

  # TODO: Uncomment when Channel model is implemented
  # has_many :channels

  # Validations
  validates :name, presence: true
  validates :mode, presence: true, inclusion: { in: MODES, message: "%{value} is not a valid mode" }
  validates :tx_frequency, presence: true
  validates :rx_frequency, presence: true
end
