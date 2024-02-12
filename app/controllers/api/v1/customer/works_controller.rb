# frozen_string_literal: true

class Api::V1::Customer::WorksController < FrontofficeController
  before_action :set_work, only: :show

  after_action :verify_authorized

  # GET /api/v1/customer/works
  def index
    authorize [:customer, :work], :index?

    works = current_user.profile_customer.works

    render json: WorkSerializer.new(
      works,
      meta: {
        total_count: works.size
      }
    ), status: :ok
  end

  # GET /api/v1/customer/works/1
  def show
    authorize @work, :show?, policy_class: Customer::WorkPolicy

    render json: WorkSerializer.new(
      @work,
      params: { action: 'show' }
    ), status: :ok
  end

  private

  def set_work
    @work = Work.find(params[:id])
  end
end
