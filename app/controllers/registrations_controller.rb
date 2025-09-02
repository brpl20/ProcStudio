# frozen_string_literal: true

class RegistrationsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
    @user = User.new
  end

  def create
    # Find or create team for the user
    team = Team.find_or_create_by(name: "Team #{params[:email].split('@').first}")

    @user = User.new(registration_params.merge(team: team))

    if @user.save
      session[:user_id] = @user.id
      flash[:success] = 'Registro realizado com sucesso! Complete seu perfil para continuar.'
      redirect_to edit_user_path(@user)
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation, :oab)
  end
end
