# frozen_string_literal: true

module Api
  module V1
    class WikiPagesController < BackofficeController
  before_action :set_team_from_params
  before_action :set_wiki_page, only: [:show, :update, :destroy, :publish, :unpublish, :lock, :unlock, :revisions, :revert]

  def index
    @wiki_pages = @team.wiki_pages
                       .includes(:created_by, :updated_by, :categories, :parent)
                       .ordered

    apply_parent_filter
    apply_published_filter
    apply_category_filter
    apply_search_filter

    render json: @wiki_pages, include: [:created_by, :updated_by, :categories]
  end

  def show
    authorize @wiki_page, policy_class: Admin::WikiPagePolicy
    render json: @wiki_page, include: [:created_by, :updated_by, :categories, :parent, :children]
  end

  def create
    @wiki_page = @team.wiki_pages.build(wiki_page_params)
    @wiki_page.created_by = current_admin
    @wiki_page.updated_by = current_admin

    authorize @wiki_page, policy_class: Admin::WikiPagePolicy

    if @wiki_page.save
      attach_categories if params[:category_ids].present?
      render json: @wiki_page, status: :created
    else
      render json: { errors: @wiki_page.errors }, status: :unprocessable_entity
    end
  end

  def update
    authorize @wiki_page, policy_class: Admin::WikiPagePolicy

    @wiki_page.updated_by = current_admin
    @wiki_page.metadata['change_summary'] = params[:change_summary] if params[:change_summary].present?

    if @wiki_page.update(wiki_page_params)
      attach_categories if params[:category_ids].present?
      render json: @wiki_page
    else
      render json: { errors: @wiki_page.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @wiki_page, policy_class: Admin::WikiPagePolicy
    @wiki_page.destroy
    head :no_content
  end

  def publish
    authorize @wiki_page, policy_class: Admin::WikiPagePolicy
    if @wiki_page.publish!
      render json: @wiki_page
    else
      render json: { errors: @wiki_page.errors }, status: :unprocessable_entity
    end
  end

  def unpublish
    authorize @wiki_page, policy_class: Admin::WikiPagePolicy
    if @wiki_page.unpublish!
      render json: @wiki_page
    else
      render json: { errors: @wiki_page.errors }, status: :unprocessable_entity
    end
  end

  def lock
    authorize @wiki_page, policy_class: Admin::WikiPagePolicy
    if @wiki_page.lock!(current_admin)
      render json: @wiki_page
    else
      render json: { errors: @wiki_page.errors }, status: :unprocessable_entity
    end
  end

  def unlock
    authorize @wiki_page, policy_class: Admin::WikiPagePolicy
    if @wiki_page.unlock!(current_admin)
      render json: @wiki_page
    else
      render json: { errors: @wiki_page.errors }, status: :unprocessable_entity
    end
  end

  def revisions
    authorize @wiki_page, :revisions?, policy_class: Admin::WikiPagePolicy
    @revisions = @wiki_page.revisions.includes(:created_by).ordered
    render json: @revisions, include: [:created_by]
  end

  def revert
    authorize @wiki_page, policy_class: Admin::WikiPagePolicy
    version_number = params[:version_number].to_i

    if @wiki_page.revert_to!(version_number, current_admin)
      render json: @wiki_page
    else
      render json: { error: 'Failed to revert to specified version' }, status: :unprocessable_entity
    end
  end

  private

  def set_team_from_params
    @team = current_admin.teams.find(params[:team_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Team not found' }, status: :not_found
  end

  def set_wiki_page
    @wiki_page = @team.wiki_pages.find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Wiki page not found' }, status: :not_found
  end

  def wiki_page_params
    params.require(:wiki_page).permit(:title, :slug, :content, :parent_id, :position, :is_published)
  end

  def attach_categories
    category_ids = params[:category_ids].select(&:present?)
    @wiki_page.category_ids = category_ids
  end

  def apply_parent_filter
    if params[:parent_id].present?
      @wiki_pages = @wiki_pages.where(parent_id: params[:parent_id])
    elsif params[:root_only] == 'true'
      @wiki_pages = @wiki_pages.root_pages
    end
  end

  def apply_published_filter
    @wiki_pages = @wiki_pages.published if params[:published_only] == 'true'
  end

  def apply_category_filter
    return unless params[:category_id].present?

    @wiki_pages = @wiki_pages.joins(:wiki_page_categories)
                             .where(wiki_page_categories: { wiki_category_id: params[:category_id] })
  end

  def apply_search_filter
    return unless params[:search].present?

    search_term = "%#{params[:search]}%"
    @wiki_pages = @wiki_pages.where('title ILIKE ? OR content ILIKE ?', search_term, search_term)
  end
    end
  end
end
