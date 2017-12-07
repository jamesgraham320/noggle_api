class GameInstanceChannel < ApplicationCable::Channel
  def subscribed
    self.current_user.online = true
    self.current_user.save
    stream_from "game_channel"
  end

  def unsubscribed
    self.current_user.online = false
    self.current_user.save

    users = User.all
    users_online = users.select {|user| user.online == true}

    if users_online.empty? && Game.find_by(running: true)
      current_game = Game.find_by(running:true)
      current_game.update(running: false)
    end
    ActionCable.server.broadcast "game_channel", {users: users_online, high_scores:Score.high_scores}

  end
end
