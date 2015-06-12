module Pages
  class DraftRoom < Base
    def has_players?
      has_css? '.player'
    end
  end
end
