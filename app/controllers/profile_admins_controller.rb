# frozen_string_literal: true

class ProfileAdminsController < ApplicationController
  before_action :retrieve_admin, only: %i[edit update show]
  before_action :verify_password, only: [:update]

  def index
    @profile_admins = ProfileAdminFilter.retrieve_admins
  end

  def new
    @profile_admin = ProfileAdmin.new
    @profile_admin.build_admin
    @profile_admin.addresses.build
  end

  def create
    @profile_admin = ProfileAdmin.new(params_profile)
    if @profile_admin.save
      redirect_to profile_admins_path, notice: 'Salvo com sucesso!'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @profile_admin.update(params_profile)
      sign_in @profile_admin.admin, bypass: true
      redirect_to profile_admins_path, notice: 'Alterado com sucesso!'
    else
      render :edit
    end
  end

  def show; end

  def delete; end

  private

  def params_profile
    params.require(:profile_admin).permit(
      :role, :name, :lastname, :gender, :oab, :rg, :cpf, :nationality, :civil_status, :birth, :mother_name, :status,
      admin_attributes: %i[id email password password_confirmation],
      addresses_attributes: %i[id description zip_code street number neighborhood city state _destroy]
    )
  end

  def retrieve_admin
    @profile_admin = ProfileAdminFilter.retrieve_admin(params[:id])
  end

  def verify_password
    password = params[:profile_admin][:admin_attributes][:password].blank?
    confirmation = params[:profile_admin][:admin_attributes][:password_confirmation].blank?

    params[:profile_admin][:admin_attributes].extract!(:password, :password_confirmation) if password && confirmation
  end
end
