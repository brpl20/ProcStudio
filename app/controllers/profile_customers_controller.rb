# frozen_string_literal: true

class ProfileCustomersController < ApplicationController
  before_action :retrieve_customer, only: %i[edit update show]
  before_action :verify_password, only: [:update]

  def index
    @profile_customers = ProfileCustomerFilter.retrieve_customers
  end

  def new
    @profile_customer = ProfileAdmin.new
    # @profile_customer.build_customer
    # @profile_customer.addresses.build
    # @profile_customer.phones.build
    # @profile_customer.emails.build
    # @profile_customer.bank_accounts.build
  end

  def create
    @profile_customer = ProfileAdmin.new(params_profile)

    case @profile_customer.type
    when 'Person'
      @profile_customer = Person.new(person_params)
    when 'Company'
      @profile_customer = Company.new(company_params)
    end

    if @profile_customer.save
      redirect_to profile_customers_path, notice: 'Salvo com sucesso!'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @profile_customer.update(params_profile)
      bypass_sign_in @profile_customer.customer
      redirect_to profile_customers_path, notice: 'Alterado com sucesso!'
    else
      render :edit
    end
  end

  def show; end

  def delete; end

  private

  def params_profile
    params.require(:profile_customer).permit(
      :type,
      :name,
      :lastname,
      :gender,
      :nationality,
      :civil_status,
      :capacity,
      :profession,
      :birth,
      :monther_name,
      :number_benefit,
      :status,
      :document,
      :nit,
      :inss_password,
      :invalid_person,
      :customer,
      customer_attributes: %i[id email password password_confirmation],
      addresses_attributes: %i[id description zip_code street number neighborhood city state _destroy],
      phones_attributes: %i[id phone _destroy],
      emails_attributes: %i[id email _destroy],
      bank_accounts_attributes: %i[id bank_name type_account agency account operation _destroy]
    )
  end

  def person_params
    params.require(:person).permit(:cpf, :rg)
  end

  def company_params
    params.require(:company).permit(:cnpj, :company)
  end

  def retrieve_customer
    @profile_customer = ProfileCustomerFilter.retrieve_customer(params[:id])
  end

  def verify_password
    password = params[:profile_customer][:admin_attributes][:password].blank?
    confirmation = params[:profile_customer][:admin_attributes][:password_confirmation].blank?

    params[:profile_customer][:admin_attributes].extract!(:password, :password_confirmation) if password && confirmation
  end
end
