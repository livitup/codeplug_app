class Network < ApplicationRecord
  # Constants
  NETWORK_TYPES = [ "Analog", "Digital-P25", "Digital-DMR" ].freeze

  # Associations
  # TODO: Uncomment when TalkGroup model is implemented
  # has_many :talkgroups, dependent: :restrict_with_error

  has_many :system_networks, dependent: :destroy
  has_many :systems, through: :system_networks

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :network_type, presence: true, inclusion: { in: NETWORK_TYPES, message: "%{value} is not a valid network type" }
  validates :website, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message: "must be a valid HTTP or HTTPS URL"
  }, allow_blank: true
end
