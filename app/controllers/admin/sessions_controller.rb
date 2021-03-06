class Admin::SessionsController < AdminController
  skip_before_action :ensure_user_signed_in

  # Used with OmniAuth::Strategies::DeveloperAdmin as the dev-facing
  # form it creates doesn't know (and doesn't need to in dev) about our CSRF token
  skip_before_action :verify_authenticity_token, only: :create if OmniAuth::Strategies::DeveloperAdmin.applies?

  def new; end

  def create
    if authorised_email?
      session[:admin_account] = user_hash
      redirect_to admin_root_path
    else
      render :not_authorised
    end
  end

  def destroy
    session[:admin_account] = nil
    redirect_to admin_root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def user_hash
    {
      'name' => auth_hash.info.name,
      'email' => auth_hash.info.email,
    }
  end

  def authorised_email?
    ENV['ADMIN_EMAILS'].split(',').include?(user_hash['email'])
  end
end
