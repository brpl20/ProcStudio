# frozen_string_literal: true

class Api::V1::DraftsController < BackofficeController
  before_action :authenticate_user!
  before_action :set_draftable_if_exists, only: [:save, :create]
  before_action :set_draft, only: [:show, :update, :recover, :destroy, :fulfill]

  def index
    drafts = Draft.active.unfulfilled
    drafts = drafts.where(team: current_team) if current_team
    drafts = drafts.where(user: current_user) if current_user

    # Separate new and existing record drafts if requested
    if params[:draft_type].present?
      drafts = case params[:draft_type]
               when 'new'
                 drafts.for_new_records
               when 'existing'
                 drafts.for_existing_records
               else
                 drafts
               end
    end

    render json: {
      success: true,
      message: 'Rascunhos obtidos com sucesso',
      data: serialize_drafts(drafts),
      meta: {
        total_count: drafts.count,
        new_records_count: drafts.for_new_records.count,
        existing_records_count: drafts.for_existing_records.count
      }
    }, status: :ok
  rescue StandardError => e
    render json: {
      success: false,
      message: e.message,
      errors: [e.message]
    }, status: :internal_server_error
  end

  def show
    render json: {
      success: true,
      message: 'Rascunho obtido com sucesso',
      data: serialize_draft(@draft)
    }, status: :ok
  rescue StandardError => e
    render json: {
      success: false,
      message: e.message,
      errors: [e.message]
    }, status: :internal_server_error
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

    render json: {
      success: true,
      message: 'Rascunho atualizado com sucesso',
      data: serialize_draft(@draft)
    }, status: :ok
  rescue StandardError => e
    render json: {
      success: false,
      message: e.message,
      errors: [e.message]
    }, status: :unprocessable_content
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

    render json: {
      success: true,
      message: 'Rascunho marcado como utilizado',
      data: serialize_draft(@draft)
    }, status: :ok
  rescue StandardError => e
    render json: {
      success: false,
      message: e.message,
      errors: [e.message]
    }, status: :unprocessable_content
  end

  def recover
    # For new record drafts, just return the draft data
    # For existing record drafts, mark as recovered
    if @draft.for_new_record?
      render json: {
        success: true,
        message: 'Rascunho de novo registro recuperado',
        data: serialize_draft(@draft),
        is_new_record: true
      }, status: :ok
    else
      @draft.recover!
      render json: {
        success: true,
        message: 'Rascunho recuperado com sucesso',
        data: serialize_draft(@draft),
        is_new_record: false
      }, status: :ok
    end
  rescue StandardError => e
    render json: {
      success: false,
      message: e.message,
      errors: [e.message]
    }, status: :unprocessable_content
  end

  def destroy
    @draft.destroy
    render json: {
      success: true,
      message: 'Rascunho removido com sucesso',
      data: { id: @draft.id }
    }, status: :ok
  rescue StandardError => e
    render json: {
      success: false,
      message: e.message,
      errors: [e.message]
    }, status: :unprocessable_content
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
    draftable_type = params[:draftable_type]
    draftable_id = params[:draftable_id]

    # For new records, draftable_id is optional or nil
    if draftable_id.blank? || draftable_id == '0'
      @draftable = nil
      return
    end

    if draftable_type.blank?
      render json: {
        success: false,
        message: 'Tipo de rascunho é obrigatório',
        errors: ['draftable_type é obrigatório']
      }, status: :bad_request
      return
    end

    @draftable = case draftable_type
                 when 'ProfileCustomer'
                   ProfileCustomer.find(draftable_id)
                 when 'UserProfile'
                   UserProfile.find(draftable_id)
                 when 'Work'
                   Work.find(draftable_id)
                 when 'Job'
                   Job.find(draftable_id)
                 else
                   render json: {
                     success: false,
                     message: "Tipo de rascunho desconhecido: #{draftable_type}",
                     errors: ["Tipo '#{draftable_type}' não é suportado. Tipos válidos: ProfileCustomer, UserProfile, Work, Job"]
                   }, status: :bad_request
                   return
                 end
  rescue ActiveRecord::RecordNotFound
    render json: {
      success: false,
      message: 'Registro não encontrado',
      errors: ["#{draftable_type} com ID #{draftable_id} não encontrado"]
    }, status: :not_found
  end

  def set_draft
    @draft = if params[:id]
               Draft.find(params[:id])
             elsif params[:session_id].present? && params[:form_type].present?
               # Find draft for new record by session_id
               Draft.find_draft_for_new_record(
                 form_type: params[:form_type],
                 user: current_user,
                 team: current_team,
                 session_id: params[:session_id]
               )
             else
               # For backwards compatibility with existing endpoints
               set_draftable_if_exists
               return unless @draftable

               @draftable.drafts.active.find_by!(form_type: params[:form_type])
             end

    raise ActiveRecord::RecordNotFound unless @draft

    authorize_draft!(@draft)
  rescue ActiveRecord::RecordNotFound
    render json: {
      success: false,
      message: 'Rascunho não encontrado',
      errors: ['Rascunho não encontrado ou expirado']
    }, status: :not_found
  end

  def authorize_draft!(draft)
    authorized = current_user && (draft.user == current_user || draft.team == current_user.team)

    return if authorized

    render json: {
      success: false,
      message: 'Acesso negado',
      errors: ['Você não tem permissão para acessar este rascunho']
    }, status: :forbidden
  end

  def serialize_draft(draft)
    {
      id: draft.id,
      draftable_type: draft.draftable_type,
      draftable_id: draft.draftable_id,
      form_type: draft.form_type,
      data: draft.data,
      status: draft.status,
      expires_at: draft.expires_at,
      created_at: draft.created_at,
      updated_at: draft.updated_at,
      user_id: draft.user_id,
      customer_id: draft.customer_id,
      team_id: draft.team_id,
      is_new_record: draft.for_new_record?,
      session_id: draft.session_id
    }
  end

  def serialize_drafts(drafts)
    drafts.map { |draft| serialize_draft(draft) }
  end

  def save_draft_action
    # Shared logic for save and create actions
    draft_params = {
      form_type: params[:form_type],
      data: params[:data].to_unsafe_h, # Convert ActionController::Parameters to Hash
      user: current_user,
      customer: nil,
      team: current_team
    }

    # Add draftable if it exists (for existing records)
    draft_params[:draftable] = @draftable if @draftable

    # Add session_id for new records
    draft_params[:session_id] = params[:session_id] if params[:session_id].present?

    draft = Draft.save_draft(**draft_params)

    render json: {
      success: true,
      message: 'Rascunho salvo com sucesso',
      data: serialize_draft(draft)
    }, status: :ok
  rescue StandardError => e
    render json: {
      success: false,
      message: e.message,
      errors: [e.message]
    }, status: :unprocessable_content
  end
end
