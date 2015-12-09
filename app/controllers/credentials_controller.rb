class CredentialsController < ApplicationController
  before_action :set_credential, only: %w(edit update destroy)
  skip_before_action :check_credential

  def create
    @credential = Credential.new(credential_params)
    if @credential.save
      redirect_to @credential, notice: 'Credential was successfully created.'
    else
      render :new
    end
  end

  def update
    if @credential.update(credential_params)
      redirect_to root_url, notice: 'Credential was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_credential
    @credential = Credential.first || Credential.send(:create_without_callbacks)
  end

  def credential_params
    params.require(:credential).permit(:client_id, :client_secret)
  end
end
