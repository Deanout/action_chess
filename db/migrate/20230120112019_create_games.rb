class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.string :state
      t.string :turn
      t.string :fen
      t.string :pgn
      t.integer :white_player_id
      t.integer :black_player_id

      t.timestamps
    end
  end
end
