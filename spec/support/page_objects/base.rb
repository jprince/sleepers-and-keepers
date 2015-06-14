module Pages
  class Base
    include Capybara::DSL

    def has_text_in_column?(column, text)
      has_css?(".#{column}", text: text)
    end
  end
end
