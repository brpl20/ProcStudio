# frozen_string_literal: true

class Api::V1::Customer::CustomersController < FrontofficeController
  before_action :set_customer

  after_action :verify_authorized

  # GET /api/v1/customer/customers/id
  def show
    authorize @customer, :show?, policy_class: Customer::CustomerPolicy

    render json: CustomerSerializer.new(
      @customer
    ), status: :ok
  end

  # PATCH /api/v1/customer/customers/id
  def update
    authorize @customer, :update?, policy_class: Customer::CustomerPolicy

    if @customer.update(customers_params)
      render json: CustomerSerializer.new(
        @customer
      ), status: :ok
    else
      render(
        status: :bad_request,
        json: { errors: [{ code: @customer.errors.full_messages }] }
      )
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customers_params
    params.require(:customer).permit(
      :email, :password, :password_confirmation
    )
  end
end
