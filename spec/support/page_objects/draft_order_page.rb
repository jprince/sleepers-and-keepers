module Pages
  class DraftOrderPage < Base
    def has_revised_draft_order?
      team_one_pick = find("input#team-#{Team.all.order(:id)[0].id}")
      team_three_pick = find("input#team-#{Team.all.order(:id)[2].id}")

      teams_have_correct_draft_picks_set =
        team_one_pick.value == '10' &&
        team_three_pick.value == '12'

      draft_order_inputs = all('#draft-order input')
      teams_in_correct_order =
        draft_order_inputs[9] == team_one_pick &&
        draft_order_inputs[11] == team_three_pick

      teams_have_correct_draft_picks_set && teams_in_correct_order
    end
  end
end
