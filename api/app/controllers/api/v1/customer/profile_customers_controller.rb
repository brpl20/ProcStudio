# frozen_string_literal: true

class Api::V1::Customer::ProfileCustomersController < FrontofficeController
  include DraftControllerConcern

  before_action :load_active_storage_url_options unless Rails.env.production?

  before_action :retrieve_customer

  # GET /api/v1/customer/profile_customers/1
  def show
    authorize @profile_customer, :show?, policy_class: Customer::ProfileCustomerPolicy

    response_data = ProfileCustomerSerializer.new(
      @profile_customer,
      { params: { action: 'show' } }
    ).serializable_hash

    if @draft_data
      response_data[:draft] = {
        id: @draft_id,
        data: @draft_data,
        expires_at: @draft_expires_at
      }
    end

    render json: response_data, status: :ok
  end

  # PATCH/PUT /api/v1/customer/profile_customers/1
  def update
    authorize @profile_customer, :update?, policy_class: Customer::ProfileCustomerPolicy

    if params[:save_as_draft] == 'true'
      save_draft_if_requested
      render json: {
        message: 'Draft saved successfully',
        draft_id: @profile_customer.drafts.last&.id
      }, status: :ok
    elsif @profile_customer.update(profile_customers_params)
      clear_draft_if_exists

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

  def clear_draft_if_exists
    draft = @profile_customer.drafts.active.find_by(form_type: params[:form_type] || 'profile_form')
    draft&.recover!
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
      addresses_attributes: [:id, :description, :zip_code, :street, :number, :neighborhood, :city, :state],
      bank_accounts_attributes: [:id, :bank_name, :account_type, :agency, :account, :operation, :pix],
      customer_attributes: [:id, :email, :password, :password_confirmation],
      phones_attributes: [:id, :phone_number],
      emails_attributes: [:id, :email],
      represent_attributes: [:id, :representor_id],
      customer_files_attributes: [:id, :file_description]
    )
    # rubocop:enable Rails/StrongParametersExpect
  end
end
