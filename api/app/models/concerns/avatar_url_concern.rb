# frozen_string_literal: true

module AvatarUrlConcern
  extend ActiveSupport::Concern

  def avatar_url(only_path: true)
    return nil unless avatar.attached?

    Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: only_path)
  rescue StandardError
    nil
  end
end
