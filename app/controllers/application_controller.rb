class ApplicationController < ActionController::Base

  before_action :check_credential

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def check_credential
    redirect_to edit_credential_url unless Credential.valid?
  end
end
