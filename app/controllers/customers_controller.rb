# frozen_string_literal: true

class CustomersController < ApplicationController
  # Temporarily disable authentication for testing
  # before_action :require_login
  before_action :set_customer, only: [:show, :edit, :update]

  def index
    @customers = ProfileCustomer.includes(:customer).page(params[:page])
  end

  def show; end

  def new
    @customer = Customer.new
    @customer.build_profile_customer
  end

  def edit; end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      redirect_to customer_path(@customer), notice: 'Cliente criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      redirect_to customer_path(@customer), notice: 'Cliente atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(
      :email, :password, :password_confirmation,
      profile_customer_attributes: [
        :id, :name, :last_name, :cpf, :cnpj, :rg, :birth, :gender,
        :civil_status, :nationality, :capacity, :mother_name, :profession,
        :company, :number_benefit, :nit, :inss_password, :customer_type,
        { phones_attributes: [:id, :phone_number, :_destroy],
          emails_attributes: [:id, :email, :_destroy],
          addresses_attributes: [:id, :description, :zip_code, :street, :number, :neighborhood, :city, :state, :_destroy],
          bank_accounts_attributes: [:id, :bank_name, :type_account, :agency, :account, :operation, :pix, :_destroy] }
      ]
    )
  end
end
