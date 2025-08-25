# frozen_string_literal: true

module Draftable
  extend ActiveSupport::Concern

  included do
    before_action :check_for_draft, only: [:show, :edit]
  end

  private

  def check_for_draft
    return unless draft_requested?

    draft = find_draft
    return unless draft

    attach_draft_to_response(draft)
  end

  def draft_requested?
    params[:with_draft].present? && params[:with_draft] == 'true'
  end

  def find_draft
    return unless defined?(@profile_customer) && @profile_customer

    @profile_customer.drafts.active.find_by(form_type: params[:form_type] || 'profile_form')
  end

  def attach_draft_to_response(draft)
    @draft_data = draft.data
    @draft_id = draft.id
    @draft_expires_at = draft.expires_at
  end

  def save_draft_if_requested
    return unless params[:save_as_draft].present? && params[:save_as_draft] == 'true'

    Draft.save_draft(
      draftable: @profile_customer,
      form_type: params[:form_type] || 'profile_form',
      data: draft_params,
      user: current_user,
      customer: current_customer,
      team: current_team
    )
  end

  def current_team
    @current_team ||= if current_user.respond_to?(:team)
                        current_user.team
                      elsif current_customer
                        TeamCustomer.find_by(customer: current_customer)&.team
                      end
  end

  def draft_params
    params.permit!.to_h.except(:save_as_draft, :with_draft, :form_type)
  end
end
