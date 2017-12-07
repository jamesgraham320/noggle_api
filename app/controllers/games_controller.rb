class GamesController < ApplicationController

  def create
    current_game = Game.find_by(running: true) || Game.new
    current_game.users = User.online
    if current_game.save
      ActionCable.server.broadcast 'game_channel', {current_game: {game_data: current_game, scores: current_game.scores, users: current_game.users}}
      sleep(65)
      current_game.running = false
      current_game.save
    else
      ActionCable.server.broadcast 'game_channel', {errors: current_game.errors}
    end
  end

  def update
    game = Game.find(params[:id])
    game.update(running: false)
    highest_score = game.scores.order('points DESC').first.points
    winner = game.scores.select {|score| score.points == highest_score}
    ActionCable.server.broadcast 'game_channel', {final_scores: {users: game.users, scores: game.scores, winner: winner}}
  end
end
