class Network < ApplicationRecord
  # Associations
  # TODO: Uncomment when TalkGroup model is implemented
  # has_many :talkgroups, dependent: :restrict_with_error

  # TODO: Uncomment when SystemNetwork join model is implemented
  # has_many :system_networks, dependent: :destroy
  # has_many :systems, through: :system_networks

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
