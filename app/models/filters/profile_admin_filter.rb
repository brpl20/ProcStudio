# frozen_string_literal: true

class ProfileAdminFilter
  class << self
    def retrieve_admins
      ProfileAdmin.all
    end

    def retrieve_admin(id)
      ProfileAdmin.find(id)
    end
  end
end
