# frozen_string_literal: true

module DeletedFilterConcern
  extend ActiveSupport::Concern

  class_methods do
    def filter_by_deleted(filter)
      case filter.to_s
      when 'with_deleted'
        with_deleted
      when 'only_deleted'
        only_deleted
      else
        all
      end
    end
  end
end
