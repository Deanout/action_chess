import { Controller } from "@hotwired/stimulus";
import { Chess } from "chess.js";
import Chessboard from "chessboardjs";
import consumer from "../consumer";

// Connects to data-controller="chess"
export default class extends Controller {
  static targets = ["state", "fen"];
  connect() {
    this.gameId = this.element.dataset.gameId;
    console.log("Connected");

    this.play();
    this.sub = this.cable();
    this.gameOver();
  }

  cable() {
    return consumer.subscriptions.create(
      {
        channel: "GameChannel",
        game_id: this.gameId,
      },
      {
        connected() {
          // Called when the subscription is ready for use on the server
          console.log("Channel Connected");
        },

        disconnected() {
          // Called when the subscription has been terminated by the server
        },

        received: (data) => {
          // Called when there's incoming data on the websocket for this channel

          this.board.position(data.fen);

          this.game.load(data.fen);
          this.fenTarget.innerHTML = data.fen;

          const pgn = data.pgn;

          this.game.loadPgn(pgn);

          // this.game.loadPgn(data.pgn);
          this.pgn_pre_tag.textContent = pgn;

          this.gameOver();
        },
      }
    );
  }

  play() {
    this.game = new Chess(this.element.dataset.fen);
    this.pgn_pre_tag = document.getElementById("pre_pgn_game_" + this.gameId);
    this.pgn_as_json = this.pgn_pre_tag.textContent;
    this.game.loadPgn(this.pgn_as_json);
    this.whiteSquareGrey = "#a9a9a9";
    this.blackSquareGrey = "#696969";
    this.player = this.element.dataset.orientation[0];

    // Need to bind this to the class
    var config = {
      draggable: true,
      position: this.element.dataset.fen,
      orientation: this.element.dataset.orientation,
      onDragStart: this.onDragStart.bind(this),
      onDrop: this.onDrop.bind(this),
      onMouseoutSquare: this.onMouseoutSquare.bind(this),
      onMouseoverSquare: this.onMouseoverSquare.bind(this),
      onSnapEnd: this.onSnapEnd.bind(this),
      pieceTheme: "/assets/pieces/{piece}.png",
    };
    this.board = Chessboard("board", config);
    this.gameOver();
  }
  removeGreySquares() {
    $("#board .square-55d63").css("background", "");
  }

  greySquare(square) {
    var $square = $("#board .square-" + square);

    var background = this.whiteSquareGrey;
    if ($square.hasClass("black-3c85d")) {
      background = this.blackSquareGrey;
    }

    $square.css("background", background);
  }

  onDragStart(source, piece) {
    // do not pick up pieces if the game is over
    if (this.gameOver()) {
      return false;
    }

    if (this.game.turn() !== this.player) {
      return false;
    }

    // or if it's not that side's turn
    if (
      (this.game.turn() === "w" && piece.search(/^b/) !== -1) ||
      (this.game.turn() === "b" && piece.search(/^w/) !== -1)
    ) {
      return false;
    }
  }

  gameOver() {
    // get state target
    if (this.game.isCheckmate()) {
      let winner = this.game.turn() === "w" ? "Black" : "White";
      this.stateTarget.innerHTML = "Checkmate, " + winner + " wins";
      return true;
    }
    if (this.game.isDraw()) {
      this.stateTarget.innerHTML = "Draw";
      return true;
    }
  }

  onDrop(source, target) {
    this.removeGreySquares();
    // see if the move is legal
    if (this.game.turn() !== this.player) {
      return "snapback";
    }

    let move;
    try {
      move = this.game.move({
        from: source,
        to: target,
        promotion: "q", // NOTE: always promote to a queen for example simplicity
      });
    } catch (e) {
      console.log(e);
    }
    // illegal move

    if (move === undefined) return "snapback";
  }

  onMouseoverSquare(square, piece) {
    if (this.game.turn() !== this.player) {
      return "snapback";
    }
    // get list of possible moves for this square
    var moves = this.game.moves({
      square: square,
      verbose: true,
    });

    // exit if there are no moves available for this square
    if (moves.length === 0) return;

    // highlight the square they moused over
    this.greySquare(square);

    // highlight the possible squares for this piece
    for (var i = 0; i < moves.length; i++) {
      this.greySquare(moves[i].to);
    }
  }
  onMouseoutSquare(square, piece) {
    this.removeGreySquares();
  }

  gameState() {
    if (this.game.isCheckmate()) {
      return "checkmate";
    }
    if (this.game.isDraw()) {
      return "draw";
    }
    return "in_progress";
  }

  onSnapEnd() {
    this.sendMove();
  }

  sendMove() {
    this.sub.perform("play_move", {
      move: this.game.history({ verbose: true }).pop(),
      fen: this.game.fen(),
      state: this.gameState(),
      pgn: this.game.pgn(),
    });
  }
}
