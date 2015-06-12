module Pages
  class League < Base
    def enter_draft
      click_link 'Join draft'
    end
  end
end
