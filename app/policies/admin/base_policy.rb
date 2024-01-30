# frozen_string_literal: true

class Admin::BasePolicy < ApplicationPolicy
  def role
    @role ||= user.profile_admin.role
  end

  ProfileAdmin.roles.keys.each do |role|
    define_method("#{role}?") do # def lawyer?
      self.role == role          #  self.role == 'lawyer'
    end                          # end
  end
end
