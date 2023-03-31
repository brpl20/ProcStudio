# frozen_string_literal: true

class ProfileCustomersController < BackofficeController
  before_action :retrieve_customer, only: %i[edit update show]

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

    if Customers.configure_profile(@profile_customer)
      redirect_to profile_customers_path, notice: 'Salvo com sucesso!'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @profile_customer.update(
      send("#{@profile_customer.type.singularize.downcase}_params")
    )
      redirect_to profile_customers_path, notice: 'Alterado com sucesso!'
    else
      render :edit
    end
  end

  def show; end

  def delete; end

  private

  def retrieve_customer
    @profile_customer = ProfileCustomerFilter.retrieve_customer(params[:id])
  end

  def profile_is_company_or_people?
    params[:type].in?(%w[Companies People])
  end

  def person_params
    params.require(:person).permit(
      :type, :name, :status, :customer_id, :lastname,
      :cpf, :rg, :birth, :gender,
      :civil_status, :nationality,
      :capacity, :profession,
      :company,
      :number_benefit,
      :nit, :monther_name,
      :inss_password,
      addresses_attributes: %i[id description zip_code street number neighborhood city state _destroy],
      bank_accounts_attributes: %i[id bank_name type_account agency account operation _destroy],
      customer_attributes: %i[id email password password_confirmation],
      phones_attributes: %i[id phone _destroy],
      emails_attributes: %i[id email _destroy]
    )
  end

  def company_params
    params.require(:company).permit(
      :type,
      :name,
      :cnpj,
      :status,
      :company,
      :customer_id,
      addresses_attributes: %i[id description zip_code street number neighborhood city state _destroy],
      bank_accounts_attributes: %i[id bank_name type_account agency account operation _destroy],
      phones_attributes: %i[id phone _destroy],
      emails_attributes: %i[id email _destroy]
    )
  end

  def representative_params
    params.require(:representative).permit(
      :name,
      :lastname,
      :cpf,
      :rg,
      :type,
      :status,
      :customer_id,
      phones_attributes: %i[id phone _destroy],
      emails_attributes: %i[id email _destroy]
    )
  end

  def accounting_params
    params.require(:accounting).permit(
      :name,
      :lastname,
      :type,
      :status,
      :customer_id,
      phones_attributes: %i[id phone _destroy],
      emails_attributes: %i[id email _destroy]
    )
  end
end
