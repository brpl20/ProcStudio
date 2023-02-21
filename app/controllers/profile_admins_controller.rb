# frozen_string_literal: true

class ProfileAdminsController < ApplicationController
  def index
    @profile_admins = ProfileAdmins.retrieve_admins
  end

  def new
    @profile_admin = ProfileAdmin.new
  end

  def create; end
  def edit; end
  def update; end
  def show; end
  def delete; end

  private

  def retrieve_admin
    
  end
end
