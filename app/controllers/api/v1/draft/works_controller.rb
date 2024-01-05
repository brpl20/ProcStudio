# frozen_string_literal: true

class Api::V1::Draft::WorksController < ApplicationController
  before_action :set_draft_work, only: %i[show update destroy]

  # GET /draft/works
  def index
    @draft_works = Draft::Work.all

    render json: @draft_works
  end

  # GET /draft/works/1
  def show
    render json: @draft_work
  end

  # POST /draft/works
  def create
    @draft_work = Draft::Work.new(draft_work_params)

    if @draft_work.save
      render json: @draft_work, status: :created
    else
      render json: @draft_work.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /draft/works/1
  def update
    if @draft_work.update(draft_work_params)
      render json: @draft_work
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
end
