class TalkGroup < ApplicationRecord
  # Associations
  belongs_to :network

  # TODO: Uncomment when SystemTalkGroup join model is implemented
  # has_many :system_talk_groups, dependent: :destroy
  # has_many :systems, through: :system_talk_groups

  # Validations
  validates :name, presence: true
  validates :talkgroup_number, presence: true, uniqueness: { scope: :network_id }
end
