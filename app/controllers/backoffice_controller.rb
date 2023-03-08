# frozen_string_literal: true

class BackofficeController < ApplicationController
  before_action :authenticate_admin!
end
