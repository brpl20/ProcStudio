# frozen_string_literal: true

class Api::V1::DraftsController < BackofficeController
  include DraftResponses

  before_action :authenticate_user!
  before_action :set_draftable_if_exists, only: [:save, :create]
  before_action :set_draft, only: [:show, :update, :recover, :destroy, :fulfill]

  def index
    drafts = Drafts::QueryService.build_query(
      current_user: current_user,
      current_team: current_team,
      draft_type: params[:draft_type]
    )

    render_success_response(
      message: 'Rascunhos obtidos com sucesso',
      data: Drafts::SerializerService.serialize_drafts(drafts),
      meta: Drafts::QueryService.build_meta(drafts)
    )
  rescue StandardError => e
    render_error_response(e)
  end

  def show
    render_success_response(
      message: 'Rascunho obtido com sucesso',
      data: Drafts::SerializerService.serialize_draft(@draft)
    )
  rescue StandardError => e
    render_error_response(e)
  end

  # POST /drafts - RESTful create
  def create
    save_draft_action
  end

  # PATCH/PUT /drafts/:id - RESTful update
  def update
    @draft.update!(
      data: params[:data].to_unsafe_h,
      expires_at: 30.days.from_now,
      status: 'draft'
    )

    render_success_response(
      message: 'Rascunho atualizado com sucesso',
      data: Drafts::SerializerService.serialize_draft(@draft)
    )
  rescue StandardError => e
    render_error_response(e, :unprocessable_content)
  end

  # POST /drafts/save - Backwards compatibility
  def save
    save_draft_action
  end

  # PATCH /drafts/:id/fulfill - Mark draft as fulfilled
  def fulfill
    created_record = nil

    # If record_type and record_id are provided, associate with created record
    if params[:record_type].present? && params[:record_id].present?
      created_record = params[:record_type].constantize.find(params[:record_id])
    end

    @draft.fulfill!(created_record)

    render_success_response(
      message: 'Rascunho marcado como utilizado',
      data: Drafts::SerializerService.serialize_draft(@draft)
    )
  rescue StandardError => e
    render_error_response(e, :unprocessable_content)
  end

  def recover
    if @draft.for_new_record?
      render_new_record_recovery
    else
      render_existing_record_recovery
    end
  rescue StandardError => e
    render_error_response(e, :unprocessable_content)
  end

  def destroy
    @draft.destroy
    render_success_response(
      message: 'Rascunho removido com sucesso',
      data: { id: @draft.id }
    )
  rescue StandardError => e
    render_error_response(e, :unprocessable_content)
  end

  private

  def authenticate_user!
    return if current_user

    render json: {
      success: false,
      message: 'Não autorizado',
      errors: ['Autenticação necessária']
    }, status: :unauthorized
  end

  def current_team
    @current_team ||= current_user.team if current_user.respond_to?(:team)
  end

  def set_draftable_if_exists
    return if skip_draftable?
    return render_missing_type_error if params[:draftable_type].blank?

    @draftable = find_draftable
  rescue Drafts::DraftableFinderService::InvalidTypeError => e
    render_invalid_type_error(e.message)
  rescue ActiveRecord::RecordNotFound
    render_record_not_found_error
  end

  def set_draft
    @draft = Drafts::DraftFinderService.find_draft(
      params: params,
      current_user: current_user,
      current_team: current_team,
      draftable: @draftable
    )

    authorize_draft!(@draft)
  rescue ActiveRecord::RecordNotFound
    render_draft_not_found_error
  end

  def authorize_draft!(draft)
    return if Drafts::AuthorizationService.authorized?(draft: draft, user: current_user)

    render json: {
      success: false,
      message: 'Acesso negado',
      errors: ['Você não tem permissão para acessar este rascunho']
    }, status: :forbidden
  end

  def save_draft_action
    draft_params = build_draft_params
    draft = Draft.save_draft(**draft_params)

    render_success_response(
      message: 'Rascunho salvo com sucesso',
      data: Drafts::SerializerService.serialize_draft(draft)
    )
  rescue StandardError => e
    render_error_response(e, :unprocessable_content)
  end

  # Draftable helpers
  def skip_draftable?
    params[:draftable_id].blank? || params[:draftable_id] == '0'
  end

  def find_draftable
    Drafts::DraftableFinderService.find(
      type: params[:draftable_type],
      id: params[:draftable_id]
    )
  end

  # Draft params builder
  def build_draft_params
    {
      form_type: params[:form_type],
      data: params[:data].to_unsafe_h,
      user: current_user,
      customer: nil,
      team: current_team,
      draftable: @draftable,
      session_id: params[:session_id]
    }.compact
  end
end
