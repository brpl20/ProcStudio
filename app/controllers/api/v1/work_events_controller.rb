class Api::V1::WorkEventsController < ApplicationController
  before_action :set_work_event, only: %i[ show update destroy ]

  # GET /work_events
  def index
    @work_events = WorkEvent.all

    render json: @work_events
  end

  # GET /work_events/1
  def show
    render json: @work_event
  end

  # POST /work_events
  def create
    @work_event = WorkEvent.new(work_event_params)

    if @work_event.save
      render json: @work_event, status: :created, location: @work_event
    else
      render json: @work_event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /work_events/1
  def update
    if @work_event.update(work_event_params)
      render json: @work_event
    else
      render json: @work_event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /work_events/1
  def destroy
    @work_event.destroy
  end

  private

  def set_work_event
    @work_event = WorkEvent.find(params[:id])
  end

  def work_event_params
    params.require(:work_event).permit(:status, :description, :date, :work_id)
  end
end
