class InsecureUsersController < ApplicationController
  before_action :set_insecure_user, only: %i[show edit update destroy]
  protect_from_forgery unless: -> { request.format.json? }

  # GET /insecure_users
  def index
    @insecure_users = InsecureUser.all
  end

  # GET /insecure_users/1
  def show; end

  # GET /insecure_users/new
  def new
    @insecure_user = InsecureUser.new
  end

  # GET /insecure_users/1/edit
  def edit; end

  # POST /insecure_users
  def create
    @insecure_user = InsecureUser.new(params[:insecure_user])

    if @insecure_user.save
      redirect_to @insecure_user, notice: 'Insecure User was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /insecure_users/1
  def update
    if @insecure_user.update(params[:insecure_user])
      redirect_to @insecure_user, notice: 'Insecure user was successfully updated.', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /insecure_users/1
  def destroy
    @insecure_user.destroy!
    redirect_to insecure_users_url, notice: 'Insecure user was successfully destroyed.', status: :see_other
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_insecure_user
    @insecure_user = InsecureUser.find(params[:id])
  end
end
