User.destroy_all

users = [
  { email: 'admin@mybank.com', password: 'password' },
  { email: 'user1@mybank.com', password: 'password' },
  { email: 'user2@mybank.com', password: 'password' }
]

users.each do |user_data|
  User.create!(user_data)
end
