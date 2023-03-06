# frozen_string_literal: true

class OfficesController < ApplicationController
  before_action :retrieve_office, only: %i[show edit update destroy]

  def index
    @offices = OfficeFilter.retrieve_offices
  end

  def show; end

  def new
    @office = Office.new
    @office.bank_accounts.build
    @iffice.emails.build
  end

  def edit; end

  def create
    @office = Office.new(office_params)

    if @office.save
      redirect_to @office, notice: 'Escritório criado com sucesso!'
    else
      render :new
    end
  end

  def update
    if @office.update(office_params)
      redirect_to @office, notice: 'Escritório atualizado com sucesso!'
    else
      render :edit
    end
  end

  def destroy
    if @office.destroy
      redirect_to offices_url, notice: 'Escritório apagado com sucesso!'
    else
      render :index, notice: 'Desculpe, houve um problema, tente novamente daqui a alguns minutos'
    end
  end

  private

  def retrieve_office
    @office = OfficeFilter.retrieve_office(params[:id])
  end

  def office_params
    params.require(:office).permit(
      :name, :cnpj, :society,
      :foundation, :site, :street,
      :number, :neighborhood, :city,
      :state, :office_type_id,
      emails_attributes: %i[id email _destroy],
      bank_accounts_attributes: %i[id bank_name type_account agency account operation _destroy]
    )
  end
end
