class SystemTalkGroup < ApplicationRecord
  # Associations
  belongs_to :system
  belongs_to :talk_group

  # TODO: Uncomment when Channel model is implemented
  # has_many :channels

  # Validations
  validates :system_id, uniqueness: { scope: [ :talk_group_id, :timeslot ] }
  validates :timeslot, inclusion: { in: [ 1, 2 ], message: "must be 1 or 2" }, allow_nil: true
end
