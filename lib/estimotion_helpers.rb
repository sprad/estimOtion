module EstimotionHelpers

  def build_json(game, cards)
    # This line is nasty, but the cards collection is a Datamapper::Collection object which has its own ideas about
    # what the optional arguments to to_json should be. These ideas conflict with what JSON thinks that they should be.
    # The fix is to translate the collection to a bog standard Array.
    card_array = cards.inject([]){|a,c| a << c; a}

    {:game => game, :cards => card_array}.to_json
  end

end
