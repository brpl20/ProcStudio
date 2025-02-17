class UpdateDocumentStatuses < ActiveRecord::Migration[7.0]
  def up
    status_mapping = {
      waiting_signature: :pending_review,
      assigned: :approved,
      finished: :signed
    }

    status_mapping.each do |old_status, new_status|
      Document.where(status: old_status).update_all(status: new_status)
    end
  end

  def down
    status_mapping = {
      pending_review: :waiting_signature,
      approved: :assigned,
      signed: :finished
    }

    status_mapping.each do |new_status, old_status|
      Document.where(status: new_status).update_all(status: old_status)
    end
  end
end
