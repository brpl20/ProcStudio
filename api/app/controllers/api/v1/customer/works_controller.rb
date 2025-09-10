# frozen_string_literal: true

class Api::V1::Customer::WorksController < FrontofficeController
  before_action :load_active_storage_url_options unless Rails.env.production?
  before_action :set_work, only: :show

  after_action :verify_authorized

  # GET /api/v1/customer/works
  def index
    authorize [:customer, :work], :index?

    works = current_user.profile_customer.works.includes(
      :documents,
      :offices,
      :user_profiles,
      :law_area,
      :powers,
      :recommendations,
      :jobs,
      :pending_documents,
      :work_events
    )

    render json: CustomerWorkSerializer.new(
      works,
      meta: {
        total_count: works.size
      },
      params: { current_user: current_user }
    ), status: :ok
  end

  # GET /api/v1/customer/works/1
  def show
    authorize @work, :show?, policy_class: Customer::WorkPolicy

    render json: CustomerWorkSerializer.new(
      @work,
      params: { current_user: current_user }
    ), status: :ok
  end

  private

  def set_work
    @work = Work.find(params[:id])
  end
end
