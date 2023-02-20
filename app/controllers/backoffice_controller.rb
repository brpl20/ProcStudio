# frozen_string_literal: true

# Class que aplica logica para models dependentes de backoffice
class BackofficeController < ApplicationController
  before_action :authenticate_admin!
end
