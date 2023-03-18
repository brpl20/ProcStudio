# frozen_string_literal: true

class ProfileCustomersController < BackofficeController
  before_action :retrieve_customer, only: %i[edit update show]
  before_action :verify_password, only: [:update]

  def index
    @profile_customers = ProfileCustomerFilter.retrieve_customers
  end

  def new
    @profile_customer = params[:type].singularize.constantize.new
    @profile_customer.emails.build
    @profile_customer.phones.build

    @profile_customer.addresses.build if profile_is_company_or_people?
    @profile_customer.bank_accounts.build if profile_is_company_or_people?
  end

  def create
    @profile_customer = params[:type].singularize.constantize.new(
      send("#{params[:type].singularize.downcase}_params")
    )

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

  def profile_is_company_or_people?
    params[:type].in?(%w[Companies People])
  end

  def params_profile
    p '----------------'
    p 'verificando os parametros gerais'
    params.require(:profile_customer).permit(
      :type,
      :name,
      :status,
      phones_attributes: %i[id phone _destroy],
      emails_attributes: %i[id email _destroy]
    )
  end

  def person_params
    params.require(:person).permit(
      :lastname,
      :cpf, :rg,
      :birth, :gender,
      :civil_status,
      :nationality,
      :capacity,
      :profession,
      :company,
      :number_benefit,
      :nit,
      :monther_name,
      :inss_password,
      addresses_attributes: %i[id description zip_code street number neighborhood city state _destroy],
      bank_accounts_attributes: %i[id bank_name type_account agency account operation _destroy],
      customer_attributes: %i[id email password password_confirmation]
    )
  end

  def company_params
    params.require(:company).permit(
      :cnpj,
      :company,
      addresses_attributes: %i[id description zip_code street number neighborhood city state _destroy],
      bank_accounts_attributes: %i[id bank_name type_account agency account operation _destroy]
    )
  end

  def representative_params
    params.require(:representative).permit(
      :lastname,
      :cpf,
      :rg
    )
  end

  def accounting_params
    params.require(:accounting).permit(:lastname)
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
