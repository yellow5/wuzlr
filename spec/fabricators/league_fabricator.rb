Fabricator(:league) do
  user!
  name { sequence { |i| "League #{i}" } }
end
