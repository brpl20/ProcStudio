# frozen_string_literal: true

class ProfileAdmins
  class << self
    def retrieve_admins
      ProfileAdmin.all
    end
  end
end
