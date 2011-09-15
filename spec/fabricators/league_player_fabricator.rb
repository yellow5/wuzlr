Fabricator(:league_player) do
  player { Fabricate(:user) }
  league
end
