# frozen_string_literal: true

namespace :delete_works do

    desc 'Delete all works and honoraries'
    task start: :environment do
        CustomerWork.delete_all
        ProfileAdminWork.delete_all
        Recommendation.delete_all
        PendingDocument.delete_all
        Document.delete_all
        JobWork.delete_all
        OfficeWork.delete_all
        PowerWork.delete_all
        Honorary.delete_all
        Work.delete_all
        p "#### All deleted ###"
    end
  end
  