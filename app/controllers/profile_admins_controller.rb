# frozen_string_literal: true

class ProfileAdminsController < ApplicationController
  def index; end

  def new
    @profile_admin = ProfileAdmin.new
  end
end
