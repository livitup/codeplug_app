class Manufacturer < ApplicationRecord
  # Associations
  has_many :radio_models, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  # Callbacks
  before_validation :strip_whitespace

  private

  def strip_whitespace
    self.name = name.strip if name.present?
  end
end
