# frozen_string_literal: true

class PowersController < ApplicationController
  before_action :retrieve_power, only: %i[edit update destroy]

  def index
    @powers = Power.all
  end

  def show; end

  def new
    @power = Power.new
  end

  def edit; end

  def create
    @power = Power.new(power_params)

    if @power.save
      redirect_to powers_index_path, notice: 'Criado com sucesso!'
    else
      render :new
    end
  end

  def update
    if @power.update(power_params)
      redirect_to powers_index_path, notice: 'Atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    if @powers.destroy
      redirect_to powers_url, notice: 'Excluído com sucesso.'
    else
      render :index, notice: 'Desculpe, houve um problema. Tente novamente daqui a alguns minutos'
    end
  end

  private

  def retrieve_power
    @power = Power.find(params[:id])
  end

  def power_params
    params.require(:power).permit(:description, :category)
  end
end
