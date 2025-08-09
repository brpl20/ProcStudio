# frozen_string_literal: true

module Api
  module V1
    class WikiCategoriesController < BackofficeController
      before_action :set_team_from_params
  before_action :set_wiki_category, only: [:show, :update, :destroy]

  def index
    @wiki_categories = @team.wiki_categories
                            .includes(:parent, :children)
                            .ordered

    if params[:parent_id].present?
      @wiki_categories = @wiki_categories.where(parent_id: params[:parent_id])
    elsif params[:root_only] == 'true'
      @wiki_categories = @wiki_categories.root_categories
    end

    render json: @wiki_categories, include: [:parent, :children]
  end

  def show
    authorize @wiki_category, policy_class: Admin::WikiCategoryPolicy
    render json: @wiki_category, include: [:parent, :children, :pages]
  end

  def create
    @wiki_category = @team.wiki_categories.build(wiki_category_params)
    authorize @wiki_category, policy_class: Admin::WikiCategoryPolicy

    if @wiki_category.save
      render json: @wiki_category, status: :created
    else
      render json: { errors: @wiki_category.errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @wiki_category, policy_class: Admin::WikiCategoryPolicy
    if @wiki_category.update(wiki_category_params)
      render json: @wiki_category
    else
      render json: { errors: @wiki_category.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @wiki_category, policy_class: Admin::WikiCategoryPolicy
    @wiki_category.destroy
    head :no_content
  end

  private

  def set_team_from_params
    @team = current_admin.teams.find(params[:team_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Team not found' }, status: :not_found
  end

  def set_wiki_category
    @wiki_category = @team.wiki_categories.find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Wiki category not found' }, status: :not_found
  end

  def wiki_category_params
    params.require(:wiki_category).permit(:name, :slug, :description, :parent_id, :position, :color, :icon)
  end
    end
  end
end
