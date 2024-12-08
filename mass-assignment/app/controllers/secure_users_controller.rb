class SecureUsersController < ApplicationController
  before_action :set_secure_user, only: %i[show edit update destroy]
  protect_from_forgery unless: -> { request.format.json? }

  # GET /secure_users
  def index
    @secure_users = SecureUser.all
  end

  # GET /secure_users/1
  def show
  end

  # GET /secure_users/new
  def new
    @secure_user = SecureUser.new
  end

  # GET /secure_users/1/edit
  def edit
  end

  # POST /secure_users
  def create
    @secure_user = SecureUser.new(secure_user_params)

    if @secure_user.save
      redirect_to @secure_user, notice: 'Secure user was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /secure_users/1
  def update
    if @secure_user.update(secure_user_params)
      redirect_to @secure_user, notice: 'Secure user was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /secure_users/1
  def destroy
    @secure_user.destroy!
    redirect_to secure_users_url, notice: 'Secure user was successfully destroyed.', status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_secure_user
    @secure_user = SecureUser.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def secure_user_params
    params.require(:secure_user).permit(:name, :email)
  end
end
