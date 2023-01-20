module ColorConcerns
  extend ActiveSupport::Concern

  def get_colors(color_choice)
    if color_choice == 'white'
      :white
    elsif color_choice == 'black'
      :black
    else
      # randomize
      %i[white black].sample
    end
  end

  def assign_colors
    color_choice = get_colors(params[:game][:color])

    if color_choice == :white
      params[:game][:white_player_id] = params[:game][:challenger_id]
      params[:game][:black_player_id] = params[:game][:challengee_id]
    else
      params[:game][:white_player_id] = params[:game][:challengee_id]
      params[:game][:black_player_id] = params[:game][:challenger_id]
    end
  end
end
