class Manufacturer < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  has_many :radio_models, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  # Callbacks
  before_validation :strip_whitespace

  # Scopes
  scope :system, -> { where(system_record: true) }
  scope :user_owned, ->(user) { where(user_id: user.id) }
  scope :visible_to, ->(user) { where(system_record: true).or(where(user_id: user.id)) }

  # Authorization methods
  def editable_by?(user)
    return false if user.nil?
    return false if system_record?
    self.user == user
  end

  private

  def strip_whitespace
    self.name = name.strip if name.present?
  end
end
