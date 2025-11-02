class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :codeplugs, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Callbacks
  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
