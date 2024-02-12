# frozen_string_literal: true

class Api::V1::Draft::WorksController < BackofficeController
  before_action :set_draft_work, only: %i[show update destroy]
  before_action :perform_authorization

  after_action :verify_authorized

  # GET /draft/works
  def index
    @draft_works = Draft::Work.all

    render json: Draft::WorkSerializer.new(
      @draft_works,
      meta: { total_count: @draft_works.offset(nil).limit(nil).count }
    ), status: :ok
  end

  # GET /draft/works/1
  def show
    render json: Draft::WorkSerializer.new(
      @draft_work,
      params: { action: 'show' }
    ), status: :ok
  end

  # POST /draft/works
  def create
    @draft_work = Draft::Work.new(draft_work_params)

    if @draft_work.save
      render json: Draft::WorkSerializer.new(
        @draft_work,
        params: { action: 'show' }
      ), status: :created
    else
      render json: @draft_work.errors, status: :unprocessable_entity
    end
  rescue StandardError => e
    render(
      status: :bad_request,
      json: { errors: [{ code: e }] }
    )
  end

  # PATCH/PUT /draft/works/1
  def update
    if @draft_work.update(draft_work_params)
      render json: Draft::WorkSerializer.new(
        @draft_work,
        params: { action: 'show' }
      ), status: :ok
    else
      render json: @draft_work.errors, status: :unprocessable_entity
    end
  end

  # DELETE /draft/works/1
  def destroy
    @draft_work.destroy
  end

  private

  def set_draft_work
    @draft_work = Draft::Work.find(params[:id])
  end

  def draft_work_params
    params.require(:draft_work).permit(:name, :work_id)
  end

  def perform_authorization
    authorize [:admin, :work], "#{action_name}?".to_sym
  end
end
