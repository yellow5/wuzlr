Fabricator(:user_stat) do
  user
  other_user { Fabricate(:user) }
end
