Fabricator(:user) do
  id            1
  username      { Faker::Name.first_name }
  email         { |attrs| "#{attrs[:username].parameterize}@example.com" }
  password      { "password" }
  confirmed_at  { Time.now }
end