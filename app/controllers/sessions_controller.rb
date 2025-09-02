# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      session[:user_id] = user.id
      flash[:success] = 'Login realizado com sucesso!'
      redirect_to root_path
    else
      flash.now[:alert] = 'Email ou senha inválidos'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = 'Logout realizado com sucesso!'
    redirect_to login_path
  end
end
