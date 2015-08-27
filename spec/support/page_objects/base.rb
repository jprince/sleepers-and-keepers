module Pages
  class Base
    include Capybara::DSL

    def has_text_in_column?(column, text)
      has_css?(".#{column}", text: text)
    end

    def select_position(position)
      select(position, from: 'position-select')
    end
  end
end
