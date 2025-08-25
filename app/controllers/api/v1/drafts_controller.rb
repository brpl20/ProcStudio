# frozen_string_literal: true

class Api::V1::DraftsController < ApplicationController
  before_action :authenticate_user_or_customer!
  before_action :set_draftable, only: [:save, :show, :recover]
  before_action :set_draft, only: [:show, :recover, :destroy]

  def index
    drafts = Draft.active
    drafts = drafts.where(team: current_team) if current_team
    drafts = drafts.where(user: current_user) if current_user
    drafts = drafts.where(customer: current_customer) if current_customer

    render json: { drafts: serialize_drafts(drafts) }, status: :ok
  end

  def save
    draft = Draft.save_draft(
      draftable: @draftable,
      form_type: params[:form_type],
      data: params[:data],
      user: current_user,
      customer: current_customer,
      team: current_team
    )

    render json: {
      draft: serialize_draft(draft),
      message: 'Draft saved successfully'
    }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    render json: { draft: serialize_draft(@draft) }, status: :ok
  end

  def recover
    @draft.recover!
    render json: {
      draft: serialize_draft(@draft),
      message: 'Draft recovered successfully'
    }, status: :ok
  end

  def destroy
    @draft.destroy
    render json: { message: 'Draft deleted successfully' }, status: :ok
  end

  private

  def authenticate_user_or_customer!
    return if current_user || current_customer

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def current_team
    @current_team ||= if current_user.respond_to?(:team)
                        current_user.team
                      elsif current_customer
                        TeamCustomer.find_by(customer: current_customer)&.team
                      end
  end

  def set_draftable
    draftable_type = params[:draftable_type]
    draftable_id = params[:draftable_id]

    @draftable = case draftable_type
                 when 'ProfileCustomer'
                   ProfileCustomer.find(draftable_id)
                 else
                   raise "Unknown draftable type: #{draftable_type}"
                 end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Record not found' }, status: :not_found
  end

  def set_draft
    @draft = if params[:id]
               Draft.find(params[:id])
             else
               @draftable.drafts.active.find_by!(form_type: params[:form_type])
             end

    authorize_draft!(@draft)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Draft not found' }, status: :not_found
  end

  def authorize_draft!(draft)
    authorized = if current_user
                   draft.user == current_user
                 elsif current_customer
                   draft.customer == current_customer
                 else
                   false
                 end

    return if authorized

    render json: { error: 'Unauthorized' }, status: :forbidden
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
      updated_at: draft.updated_at
    }
  end

  def serialize_drafts(drafts)
    drafts.map { |draft| serialize_draft(draft) }
  end
end
