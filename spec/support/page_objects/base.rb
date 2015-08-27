module Pages
  class Base
    include Capybara::DSL

    def get_player_name(player)
      "#{player.last_name}, #{player.first_name}"
    end

    def has_text_in_column?(column, text)
      has_css?(".#{column}", text: text)
    end

    def select_position(position)
      select(position, from: 'position-select')
    end
  end
end
