# frozen_string_literal: true

class OfficeTypesController < ApplicationController
  before_action :retrieve_office_type, only: %i[edit update destroy]

  def index
    @office_types = OfficeType.all
  end

  def show; end

  def new
    @office_types = OfficeType.new
  end

  def edit; end

  def create
    @office_type = OfficeType.new(office_type_params)

    if @office_type.save
      redirect_to office_types_index_path, notice: 'Tipo para escritório criado com sucesso!'
    else
      render :new
    end
  end

  def update
    if @office_types.update(office_type_params)
      redirect_to office_types_index_path, notice: 'Tipo de escritório atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    if @office_types.destroy
      redirect_to office_types_url, notice: 'Tipo de escritório excluído com sucesso.'
    else
      render :index, notice: 'Desculpe, houve um problema, tente novamente daqui a alguns minutos'
    end
  end

  private

  def retrieve_office_type
    @office_types = OfficeType.find(params[:id])
  end

  def office_type_params
    params.require(:office_type).permit(:description)
  end
end
