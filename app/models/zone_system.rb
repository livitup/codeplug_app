class ZoneSystem < ApplicationRecord
  # Associations
  belongs_to :zone
  belongs_to :system
  has_many :zone_system_talkgroups, class_name: "ZoneSystemTalkGroup", dependent: :destroy
  has_many :system_talkgroups, through: :zone_system_talkgroups, source: :system_talk_group

  # Validations
  validates :zone, presence: true
  validates :system, presence: true
  validates :position, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :system_id, uniqueness: { scope: :zone_id }
  validates :position, uniqueness: { scope: :zone_id }
end
