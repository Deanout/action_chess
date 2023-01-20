class Game < ApplicationRecord
  has_many :playables, dependent: :destroy
  has_many :users, through: :playables

  enum state: { in_progress: 0, checkmate: 1, draw: 2 }
  enum turns: { white: 0, black: 1 }

  before_create :set_fen
  before_create :set_pgn

  def set_fen
    turn_abbreviation = if turn == 'white'
                          'w'
                        else
                          'b'
                        end

    self.fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR #{turn_abbreviation} KQkq - 0 1"
  end

  def set_pgn
    self.pgn =
'
[Event "Casual Game"]
[Site "Localhost"]
[Date "01/20/23"]
[EventDate "?"]
[Round "?"]
[Result "1-0"]
[White "?"]
[Black "?"]
[ECO "?"]
[WhiteElo "?"]
[BlackElo "?"]
[PlyCount "?"]
'
  end

  # used to rotate board for black player
  def orientation(user)
    if white_player_id == user.id
      'white'
    else
      'black'
    end
  end
end
