# frozen_string_literal: true

class Api::V1::LawAreasController < BackofficeController
  include TeamScoped

  before_action :retrieve_law_area, only: [:show, :update, :destroy]
  before_action :perform_authorization

  after_action :verify_authorized

  def index
    # Áreas do sistema + áreas customizadas do team atual
    law_areas = LawArea.system_areas
                  .or(LawArea.where(created_by_team: @current_user.team))
                  .active
                  .includes(:parent_area, :sub_areas)
                  .ordered

    render json: LawAreaSerializer.new(
      law_areas,
      include: [:parent_area, :sub_areas],
      meta: {
        total_count: law_areas.count,
        main_areas_count: law_areas.main_areas.count,
        sub_areas_count: law_areas.sub_areas.count
      }
    ), status: :ok
  end

  def show
    render json: LawAreaSerializer.new(
      @law_area,
      include: [:parent_area, :sub_areas, :powers]
    ), status: :ok
  end

  def create
    law_area = LawArea.new(law_area_params)

    # Se não é área do sistema, associa ao team do usuário
    law_area.created_by_team = @current_user.team unless law_area.system_area?

    if law_area.save
      render json: LawAreaSerializer.new(
        law_area,
        include: [:parent_area]
      ), status: :created
    else
      render json: {
        success: false,
        errors: law_area.errors.full_messages
      }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: {
      success: false,
      errors: [e.message]
    }, status: :bad_request
  end

  def update
    if @law_area.update(law_area_params)
      render json: LawAreaSerializer.new(
        @law_area,
        include: [:parent_area, :sub_areas]
      ), status: :ok
    else
      render json: {
        success: false,
        errors: @law_area.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @law_area.powers.exists?
      render json: {
        success: false,
        errors: ['Não é possível excluir área do direito que possui poderes associados']
      }, status: :unprocessable_entity
    elsif @law_area.sub_areas.exists?
      render json: {
        success: false,
        errors: ['Não é possível excluir área do direito que possui subáreas']
      }, status: :unprocessable_entity
    else
      @law_area.destroy
      head :no_content
    end
  end

  private

  def law_area_params
    params.expect(law_area: [:name, :code, :description, :active, :sort_order, :parent_area_id])
  end

  def retrieve_law_area
    # Só permite acesso a áreas do sistema ou do próprio team
    @law_area = LawArea.system_areas
                  .or(LawArea.where(created_by_team: @current_user.team))
                  .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def perform_authorization
    authorize [:admin, :law_area], :"#{action_name}?"
  end
end
