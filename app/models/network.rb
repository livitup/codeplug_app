class Network < ApplicationRecord
  # Associations
  # TODO: Uncomment when TalkGroup model is implemented
  # has_many :talkgroups, dependent: :restrict_with_error

  # TODO: Uncomment when SystemNetwork join model is implemented
  # has_many :system_networks, dependent: :destroy
  # has_many :systems, through: :system_networks

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :website, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message: "must be a valid HTTP or HTTPS URL"
  }, allow_blank: true
end
