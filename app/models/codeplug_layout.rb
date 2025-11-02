class CodeplugLayout < ApplicationRecord
  # Associations
  belongs_to :radio_model
  belongs_to :user, optional: true

  # Serialization
  serialize :layout_definition, type: Hash, coder: JSON

  # Validations
  validates :name, presence: true
  validates :radio_model, presence: true
  validates :layout_definition, presence: true
end
