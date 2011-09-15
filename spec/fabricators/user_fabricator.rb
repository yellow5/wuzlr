Fabricator(:user) do
  name     { sequence { |i| "User #{i}" } }
  email    { sequence { |i| "user#{i}@example.com" } }
  password 'asdf1234'
end
