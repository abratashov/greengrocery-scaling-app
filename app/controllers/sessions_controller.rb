class SessionsController < Devise::SessionsController
  skip_before_action :verify_signed_out_user, only: :destroy

  def create
    result = SignInUser.call(
      tenant_name: params[:tenant_name],
      email: params.dig(:user, :email),
      password: params.dig(:user, :password),
      session: session
    )

    if result.success?
      session[:signed_in_user_id] = result.user.id
      set_flash_message!(:notice, :signed_in)
      redirect_to tenant_path(result.tenant.name)
    else
      flash.now[:alert] = result.message
      render :new, status: :unauthorized
    end
  end

  def destroy
    reset_session

    redirect_to tenant_path(params[:tenant_name] || Tenant::DEFAULT_TENANT), status: :see_other
  end
end
