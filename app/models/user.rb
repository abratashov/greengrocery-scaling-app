class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  acts_as_tenant(:tenant)

  belongs_to :tenant
  has_many :orders, dependent: :destroy

  validates :email, uniqueness: { scope: :tenant_id, message: :non_uniqueness_in_tenant }
  validates :tenant, presence: true

  def self.find_for_authentication(warden_conditions)
    tenant_name = warden_conditions[:tenant_name]
    tenant = Tenant.find_by!(name: tenant_name)
    where(tenant: tenant).find_by(email: warden_conditions[:email])
  end
end
