class RepeaterSearchesController < ApplicationController
  before_action :set_repeater_search, only: %i[show edit update destroy]

  # GET /repeater_searches
  def index
    @repeater_searches = RepeaterSearch.all
  end

  # GET /repeater_searches/1
  def show
  end

  # GET /repeater_searches/new
  def new
    @repeater_search = RepeaterSearch.new
  end

  # GET /repeater_searches/1/edit
  def edit
  end

  # POST /repeater_searches
  def create
    @repeater_search = RepeaterSearch.new(repeater_search_params)

    if @repeater_search.save
      redirect_to @repeater_search, notice: "Repeater search was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /repeater_searches/1
  def update
    if @repeater_search.update(repeater_search_params)
      redirect_to @repeater_search, notice: "Repeater search was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /repeater_searches/1
  def destroy
    @repeater_search.destroy
    redirect_to repeater_searches_url, notice: "Repeater search was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_repeater_search
    @repeater_search = RepeaterSearch.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def repeater_search_params
    params.fetch(:repeater_search, {})
  end
end
