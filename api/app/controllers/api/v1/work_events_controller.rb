# frozen_string_literal: true

class Api::V1::WorkEventsController < BackofficeController
  before_action :set_work_event, only: [:show, :update]
  before_action :set_deleted_work_event, only: [:restore]
  before_action :perform_authorization

  # GET api/v1/work_events
  def index
    work_events = WorkEvent.all

    filter_by_deleted_params.each do |key, value|
      next if value.blank?

      work_events = work_events.public_send("filter_by_#{key}", value.strip)
    end

    work_events = work_events.order(id: :desc).limit(params[:limit])

    render json: WorkEventSerializer.new(
      work_events,
      meta: {
        total_count: work_events.size
      }
    ), status: :ok
  end

  # GET api/v1/work_events/1
  def show
    render json: WorkEventSerializer.new(@work_event), status: :ok
  end

  # POST api/v1/work_events
  def create
    work_event = WorkEvent.new(work_event_params)

    if work_event.save
      render json: WorkEventSerializer.new(work_event), status: :created
    else
      render(
        status: :unprocessable_entity,
        json: { errors: [{ code: work_event.errors.full_messages }] }
      )
    end
  rescue StandardError => e
    render(
      status: :bad_request,
      json: { errors: [{ code: e }] }
    )
  end

  # PATCH/PUT api/v1/work_events/1
  def update
    if @work_event.update(work_event_params)
      render json: WorkEventSerializer.new(@work_event), status: :ok
    else
      render(
        status: :unprocessable_entity,
        json: { errors: [{ code: @work_event.errors.full_messages }] }
      )
    end
  rescue StandardError => e
    render(
      status: :bad_request,
      json: { errors: [{ code: e }] }
    )
  end

  # DELETE api/v1/work_events/1
  def destroy
    if destroy_fully?
      WorkEvent.with_deleted.find(params[:id]).destroy_fully!
    else
      set_work_event
      @work_event.destroy
    end
  end

  # POST api/v1/work_events/1
  def restore
    if @work_event.recover
      render json: WorkEventSerializer.new(@work_event), status: :ok
    else
      render(
        status: :unprocessable_entity,
        json: { errors: [{ code: @work_event.errors.full_messages }] }
      )
    end
  rescue StandardError => e
    render(
      status: :bad_request,
      json: { errors: [{ code: e }] }
    )
  end

  private

  def set_work_event
    @work_event = WorkEvent.find(params[:id])
  end

  def set_deleted_work_event
    @work_event = WorkEvent.with_deleted.find(params[:id])
  end

  def work_event_params
    params.expect(work_event: [:description, :date, :work_id])
  end

  def perform_authorization
    authorize [:admin, :work_event], :"#{action_name}?"
  end
end
