# frozen_string_literal: true

class ProfileAdminFilter
  class << self
    def retrieve_admin(id)
      ProfileAdmin.find(id)
    end

    def retrieve_admins
      ProfileAdmin.includes(:admin).all
    end
  end
end
