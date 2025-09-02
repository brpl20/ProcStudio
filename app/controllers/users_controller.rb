# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_login
  before_action :set_user, only: [:show, :edit, :update]

  def index
    @users = current_user.team.users.includes(:user_profile)
  end

  def show; end

  def new
    @user_profile = UserProfile.new
    @user_profile.build_user
  end

  def edit; end

  def create
    @user_profile = UserProfile.new(user_profile_params)
    @user_profile.user.team = current_user.team if @user_profile.user

    if @user_profile.save
      flash[:success] = 'Usuário criado com sucesso!'
      redirect_to users_path
    else
      flash.now[:alert] = @user_profile.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_update_params)
      flash[:success] = 'Usuário atualizado com sucesso!'
      redirect_to user_path(@user)
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user.team.users.find(params[:id])
  end

  def user_profile_params
    params.require(:user_profile).permit(
      :name, :last_name, :cpf, :rg, :role, :gender,
      :civil_status, :nationality, :birth, :oab,
      user_attributes: [:email, :password, :password_confirmation]
    )
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :oab)
  end

  def user_update_params
    # Don't require password on update
    if params[:user][:password].blank?
      params.require(:user).permit(:email, :oab)
    else
      user_params
    end
  end
end
