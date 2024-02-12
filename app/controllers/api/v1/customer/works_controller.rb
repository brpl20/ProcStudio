# frozen_string_literal: true

class Api::V1::Customer::WorksController < FrontofficeController
  before_action :set_work, only: :show

  # GET /api/v1/customer/works
  def index
  end

  # GET /api/v1/customer/works/1
  def show
  end

  private

  def set_work
    @work = Work.find(params[:id])
  end
end
