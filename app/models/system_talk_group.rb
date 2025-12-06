class SystemTalkGroup < ApplicationRecord
  # Associations
  belongs_to :system
  belongs_to :talk_group

  # TODO: Uncomment when Channel model is implemented
  # has_many :channels

  # Validations
  validates :system_id, uniqueness: { scope: [ :talk_group_id, :timeslot ] }
  validates :timeslot, inclusion: { in: [ 1, 2 ], message: "must be 1 or 2" }, allow_nil: true
  validate :timeslot_required_for_dmr
  validate :mode_supports_talkgroups
  validate :talkgroup_network_matches_system

  private

  def timeslot_required_for_dmr
    return unless system&.mode == "dmr" && timeslot.nil?

    errors.add(:timeslot, "is required for DMR systems")
  end

  def mode_supports_talkgroups
    return unless system&.mode == "analog"

    errors.add(:base, "Analog systems cannot be associated with talkgroups")
  end

  def talkgroup_network_matches_system
    return unless system && talk_group

    case system.mode
    when "p25"
      validate_p25_network
    when "dmr"
      validate_dmr_network
    end
  end

  def validate_p25_network
    return if talk_group.network&.network_type == "Digital-P25"

    errors.add(:base, "P25 systems can only use talkgroups from P25 networks")
  end

  def validate_dmr_network
    return if system.networks.exists?(id: talk_group.network_id)

    errors.add(:base, "DMR systems can only use talkgroups from their associated networks")
  end
end
