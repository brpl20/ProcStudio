# frozen_string_literal: true

class ProfileCustomersController < ApplicationController
  before_action :retrieve_customer, only: %i[edit update show]
  before_action :verify_password, only: [:update]

  def index
    @profile_customers = ProfileCustomerFilter.retrieve_customers
  end

  def new
    @profile_customer = ProfileAdmin.new
    @profile_customer.phones.build
    @profile_customer.emails.build
    @profile_customer.addresses.build if params[:type] == 'Companies' || params[:type] == 'People'
    @profile_customer.bank_accounts.build if params[:type] == 'Companies' || params[:type] == 'People'
  end

  def create
    @profile_customer = ProfileAdmin.new(params_profile)

    case @profile_customer.type
    when 'Person'
      @profile_customer = Person.new(person_params)
    when 'Company'
      @profile_customer = Company.new(company_params)
    when 'Accounting'
      @profile_customer = Accounting.new(accounting_params)
    when 'Representavive'
      @profile_customer = Representavive.new(representavive_params)
    end

    if @profile_customer.save
      redirect_to profile_customers_path, notice: 'Salvo com sucesso!'
    else
      render :new
    end
  end

  def edit; end

  def update
    flag = false
    case @profile_customer.type
    when 'Person'
      flag = true if @profile_customer.update(person_profile)
    when 'Company'
      flag = true if @profile_customer.update(company_params)
    when 'Accounting'
      flag = true if @profile_customer.update(accounting_params)
    when 'Representavive'
      flag = true if @profile_customer.update(representative_params)
    end

    if flag
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
      files: [],
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
