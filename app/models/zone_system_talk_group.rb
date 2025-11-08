class ZoneSystemTalkGroup < ApplicationRecord
  # Associations
  belongs_to :zone_system
  belongs_to :system_talk_group

  # Validations
  validates :zone_system, presence: true
  validates :system_talk_group, presence: true
  validates :system_talk_group_id, uniqueness: { scope: :zone_system_id }
  validate :system_talk_group_must_belong_to_zone_system_system

  private

  def system_talk_group_must_belong_to_zone_system_system
    return if zone_system.nil? || system_talk_group.nil?

    if system_talk_group.system_id != zone_system.system_id
      errors.add(:system_talk_group, "must belong to the same system as the zone system")
    end
  end
end
