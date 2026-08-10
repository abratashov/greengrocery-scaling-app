class SignInUser
  include Interactor

  def call
    tenant = Tenant.find_by!(name: context.tenant_name)
    user = User.find_for_authentication(email: context.email, tenant_name: tenant.name)

    if user&.valid_password?(context.password)
      context.user = user
      context.tenant = tenant
      context.session[:user_id] = user.id
    else
      context.fail!(message: "Invalid email or password")
    end
  rescue ActiveRecord::RecordNotFound
    context.fail!(message: "Tenant not found")
  end
end
