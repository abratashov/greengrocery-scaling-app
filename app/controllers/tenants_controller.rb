class TenantsController < ApplicationController
  before_action :set_tenant, only: %i[show]

  def show
    @products = Product.where(tenant: @tenant).available.order(:name)
  end

  private

  def set_tenant
    @tenant = Tenant.find_by!(name: params[:tenant_name])
    ActsAsTenant.current_tenant = @tenant
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Tenant not found"
  end
end
