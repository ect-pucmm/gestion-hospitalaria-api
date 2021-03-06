class Person < ApplicationRecord
  before_save {self.email = email.downcase unless email.blank?}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :identification, presence: true, uniqueness: true
  validates :name, presence: true
  validates :last_name, presence: true
  validates :genre, inclusion: {in: %w[Masculino Femenino]}
  validates :birthday, presence: true
  validates :email, uniqueness: {case_sensitive: false}, format: {with: VALID_EMAIL_REGEX}, if: :email_not_blank?
  # Falta el inclusion (verificar que manda React)
  validates :civil_status, presence: true

  has_one :patient, dependent: :destroy
  has_one :user, dependent: :destroy

  def display_name
    identification + ' - ' + name + ' ' + last_name
  end

  def email_not_blank?
    !email.blank?
  end

  def get_all_attrs
    attributes.except(:id.to_s, :created_at.to_s, :updated_at.to_s)
  end
end
