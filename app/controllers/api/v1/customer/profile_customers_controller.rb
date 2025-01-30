# frozen_string_literal: true

class Api::V1::Customer::ProfileCustomersController < FrontofficeController
  before_action :load_active_storage_url_options unless Rails.env.production?

  before_action :retrieve_customer

  # GET /api/v1/customer/profile_customers/1
  def show
    # authorize @profile_customer, :show?, policy_class: Customer::ProfileCustomerPolicy

    render json: ProfileCustomerSerializer.new(
      @profile_customer,
      { params: { action: 'show' } }
    ), status: :ok
  end

  # PATCH/PUT /api/v1/customer/profile_customers/1
  def update
    # authorize @profile_customer, :update?, policy_class: Customer::ProfileCustomerPolicy

    if @profile_customer.update(profile_customers_params)

      render json: ProfileCustomerSerializer.new(
        @profile_customer,
        params: { action: 'show' }
      ), status: :ok
    else
      render(
        status: :bad_request,
        json: { errors: [{ code: @profile_customer.errors.full_messages }] }
      )
    end
  end

  private

  def retrieve_customer
    @profile_customer = ProfileCustomerFilter.retrieve_customer(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def profile_customers_params
    params.require(:profile_customer).permit(
      :customer_type, :name, :status, :customer_id, :last_name,
      :cpf, :rg, :birth, :gender, :cnpj,
      :civil_status, :nationality,
      :capacity, :profession,
      :company,
      :number_benefit,
      :nit, :mother_name,
      :inss_password,
      :accountant_id,
      addresses_attributes: %i[id description zip_code street number neighborhood city state],
      bank_accounts_attributes: %i[id bank_name type_account agency account operation pix],
      customer_attributes: %i[id email password password_confirmation],
      phones_attributes: %i[id phone_number],
      emails_attributes: %i[id email],
      represent_attributes: %i[id representor_id],
      customer_files_attributes: %i[id file_description]
    )
  end
end
