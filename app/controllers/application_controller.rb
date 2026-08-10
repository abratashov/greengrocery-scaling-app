class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_tenant

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def set_current_tenant
    @signed_in_user = User.find_by(id: session[:signed_in_user_id]) if session[:signed_in_user_id].present?

    tenant_name = params[:tenant_name]
    return ActsAsTenant.current_tenant = nil unless tenant_name.present?

    tenant = Tenant.find_by(name: tenant_name)
    ActsAsTenant.current_tenant = tenant
  end

  def require_signed_in_user!
    return if signed_in_user?

    tenant_name = ActsAsTenant.current_tenant&.name || params[:tenant_name]
    redirect_to tenant_name.present? ? new_user_session_path(tenant_name: tenant_name) : root_path
  end

  def signed_in_user?
    session[:user_id].present?
  end
end
