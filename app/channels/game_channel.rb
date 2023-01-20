class GameChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "game_#{params[:game_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def play_move(data)
    game = Game.find(params[:game_id])

    game.turn = if game.turn == :white
                  :black
                else
                  :white
                end
    # convert string to enum
    game.state = Game.states[data['state']] if data['state']

    game.fen = data['fen']

    game.pgn = data['pgn']

    game.save
    data['turn'] = game.turn

    ActionCable.server.broadcast("game_#{params[:game_id]}", data)
  end
end
