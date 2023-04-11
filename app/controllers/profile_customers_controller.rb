# frozen_string_literal: true

require 'docx'
require 'tempfile'

class ProfileCustomersController < BackofficeController
  before_action :retrieve_customer, only: %i[edit update show]

  def index
    @profile_customers = ProfileCustomerFilter.retrieve_customers
    generate_docx_and_upload_to_s3
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

    if Customers.configure_profile(@profile_customer, params)
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

  def generate_docx_and_upload_to_s3
    Aws.config.update(
      {
        region: 'us-west-2',
        credentials: Aws::Credentials.new(
          ENV['AWS_ID'],
          ENV['AWS_SECRET_KEY']
        )
      }
    )
    aws_client = Aws::S3::Client.new
    aws_doc = aws_client.get_object(bucket: 'prcstudio3herokubucket', key: 'base/procuracao_simples.docx')
    doc = Docx::Document.open(aws_doc.body)

    doc.paragraphs.each do |p|
      p.each_text_run do |tr|
        tr.substitute('_qualify_', 'Qualificação vai aqui')
      end
    end

    doc.save(Rails.root.join('tmp/procuração_teste.docx').to_s)
  end

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
      :nit, :mother_name,
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
