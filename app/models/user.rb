class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :playables
  has_many :games, through: :playables

  def game_in_progress_with(target_user)
    games
      .where(id: target_user.games)
      .where(state: :in_progress)
  end
end
