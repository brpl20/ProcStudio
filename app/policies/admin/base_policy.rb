# frozen_string_literal: true

class Admin::BasePolicy < ApplicationPolicy
  def role
    @role ||= user&.profile_admin&.role
  end

  def owner?
    record.created_by_id == user.id
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
