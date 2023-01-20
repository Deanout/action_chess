class GamesController < ApplicationController
  before_action :set_game, only: %i[show edit update destroy]
  before_action :authenticate_user!
  include ColorConcerns

  # GET /games or /games.json
  def index
    @games = Game.all
  end

  # GET /games/1 or /games/1.json
  def show; end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit; end

  # POST /games or /games.json
  def create
    assign_colors
    @game = Game.new(turn: :white,
                     state: :in_progress,
                     white_player_id: params[:game][:white_player_id],
                     black_player_id: params[:game][:black_player_id])

    respond_to do |format|
      if @game.save
        Playable.create(game: @game, user_id: params[:game][:challenger_id])
        Playable.create(game: @game, user_id: params[:game][:challengee_id])
        format.html { redirect_to game_url(@game), notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1 or /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to game_url(@game), notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(
      :color,
      :challenger_id,
      :challengee_id
    )
  end
end
