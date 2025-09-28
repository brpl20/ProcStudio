# frozen_string_literal: true

module Draftable
  extend ActiveSupport::Concern

  included do
    has_many :drafts, as: :draftable, dependent: :destroy

    # Define available form types for each model
    class_attribute :draftable_form_types
    self.draftable_form_types = []
  end

  class_methods do
    def draft_form_types(*types)
      self.draftable_form_types = types.map(&:to_s)
    end
  end

  def active_drafts
    drafts.active
  end

  def draft_for(form_type, team: nil)
    scope = drafts.active.where(form_type: form_type)
    scope = scope.where(team: team) if team
    scope.first
  end

  def save_draft(options = {})
    validate_form_type!(options[:form_type])
    if new_record?
      save_standalone_draft(options)
    else
      save_associated_draft(options)
    end
  end

  def has_draft?(form_type = nil, team: nil)
    scope = drafts.active
    scope = scope.where(form_type: form_type) if form_type
    scope = scope.where(team: team) if team
    scope.exists?
  end

  def recover_draft!(form_type, team: nil)
    draft = draft_for(form_type, team: team)
    return nil unless draft

    draft.recover!
    draft
  end

  def clear_drafts!(form_type = nil, team: nil)
    scope = drafts
    scope = scope.where(form_type: form_type) if form_type
    scope = scope.where(team: team) if team
    scope.destroy_all
  end

  def mark_draft_fulfilled!(form_type, team: nil)
    draft = draft_for(form_type, team: team)
    return unless draft

    draft.fulfill!(self)
  end

  # Class method to handle draft fulfillment after record creation
  def self.fulfill_draft_after_create(record, session_id: nil, form_type: nil, user: nil)
    return unless session_id || form_type

    # Find the draft for this new record
    draft = Draft.find_draft_for_new_record(
      form_type: form_type,
      user: user,
      team: record.respond_to?(:team) ? record.team : nil,
      session_id: session_id
    )

    # Fulfill the draft and associate it with the created record
    draft&.fulfill!(record)
  end

  # Check if there's an unfulfilled draft for this record
  def has_unfulfilled_draft?(form_type = nil)
    scope = drafts.unfulfilled
    scope = scope.where(form_type: form_type) if form_type
    scope.exists?
  end

  private

  def validate_form_type!(form_type)
    return if draftable_form_types.include?(form_type.to_s)

    raise ArgumentError,
          "Invalid form_type '#{form_type}' for #{self.class.name}. Valid types: #{draftable_form_types.join(', ')}"
  end

  def save_standalone_draft(options)
    Draft.save_draft(
      draftable: nil,
      form_type: options[:form_type],
      data: options[:data],
      user: options[:user],
      customer: options[:customer],
      team: options[:team],
      session_id: options[:session_id]
    )
  end

  def save_associated_draft(options)
    Draft.save_draft(
      draftable: self,
      form_type: options[:form_type],
      data: options[:data],
      user: options[:user],
      customer: options[:customer],
      team: options[:team]
    )
  end
end
