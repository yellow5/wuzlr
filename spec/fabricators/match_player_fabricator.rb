Fabricator(:match_player) do
  player   { Fabricate(:user) }
  match
  team     { MatchPlayer::TEAM_COLORS.sample }
  position { MatchPlayer::POSITION_RANGE.to_a.sample }
end
