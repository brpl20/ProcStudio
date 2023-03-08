# frozen_string_literal: true

class PowersController < ApplicationController
  before_action :retrieve_power, only: %i[edit update destroy]

  def index
    @powers = Power.all
  end

  def show; end

  def new
    @powers = OfficeType.new
  end

  def edit; end

  def create
    @power = power.new(power_params)

    if @power.save
      redirect_to powers_index_path, notice: 'Poder para escritório criado com sucesso!'
    else
      render :new
    end
  end

  def update
    if @powers.update(power_params)
      redirect_to powers_index_path, notice: 'Poder de escritório atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    if @powers.destroy
      redirect_to powers_url, notice: 'Poder de escritório excluído com sucesso.'
    else
      render :index, notice: 'Desculpe, houve um problema, tente novamente daqui a alguns minutos'
    end
  end

  private

  def retrieve_power
    @office_types = OfficeType.find(params[:id])
  end

  def power_params
    params.require(:power).permit(:description, :category)
  end
end