# frozen_string_literal: true

class Admin::BasePolicy < ApplicationPolicy
  def role
    @role ||= admin_user&.profile_admin&.role
  end

  def owner?
    record.created_by_id == admin_user.id
  end
  
  def admin_user
    # Handle both old format (user object) and new format (hash with admin/team)
    user.is_a?(Hash) ? user[:admin] : user
  end
  
  def current_team
    user.is_a?(Hash) ? user[:team] : nil
  end

  # Define methods for each role
  #
  # def lawyer?
  #  self.role == 'lawyer'
  # end
  ProfileAdmin.roles.each_key do |role|
    define_method("#{role}?") do
      self.role == role
    end
  end
end
