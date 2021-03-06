class User < ApplicationRecord
  has_secure_password

  validates :role_id, presence: true
  validates :specialty_id, presence: true, :if => :doctor?
  validates :entry_time, presence: true
  validates :departure_time, presence: true

  belongs_to :person, optional: true, dependent: :destroy
  belongs_to :role
  belongs_to :specialty, optional: true
  belongs_to :work_day, optional: true, dependent: :destroy

  has_many :vacations
  has_many :appointments
  # has_and_belongs_to_many :vacation
  # has_and_belongs_to_many :medic_license
  # has_and_belongs_to_many :permission

  before_destroy :delete_appointments

  validates :password, length: {minimum: 6}, if: -> { new_record? || !password.nil? }

  def admin?
    role.name == 'Administrador'
  end

  def doctor?
    role.name == 'Doctor'
  end

  def nurse?
    role.name == 'Enfermera'
  end

  def secretary?
    role.name == 'Secretaria'
  end

  def display_name
    person.identification + ' - ' + person.name + ' ' + person.last_name
  end

  def get_attrs
    attributes.except(:id.to_s, :person_id.to_s, :role_id.to_s, :specialty_id.to_s, :work_day_id.to_s, :password_digest.to_s)
  end

  def get_all_attrs
    info = {}
    info.merge!(id: id)
    info.merge!(person.get_all_attrs)
    info.merge!(get_attrs)
    info.merge!(role: role.name)
    info.merge!(specialty: specialty.name) if doctor?
    info.merge!(work_day.get_all_attrs) unless work_day.nil?
    return info
  end

  def appointments
    Appointment.with_deleted.where("doctor_id = ? OR secretary_id = ?", self.id, self.id)
  end

  def delete_appointments
    appointments.each do |a|
      a.really_destroy!
    end
  end
end
