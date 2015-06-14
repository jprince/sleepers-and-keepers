module Pages
  class League < Base
    def enter_draft
      click_link 'Join draft'
    end

    def has_empty_draft_results?
      has_text_in_column?('round', 1) &&
      has_text_in_column?('round-pick', 1) &&
      has_text_in_column?('team', Team.first.name) &&
      has_text_in_column?('player', '')
    end
  end
end
