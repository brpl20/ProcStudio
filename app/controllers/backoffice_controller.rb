# frozen_string_literal: true

class BackofficeController < ApplicationController
  include JwtAuth
  before_action :authenticate_admin
end
