Order.destroy_all
User.destroy_all

ActiveRecord::Base.connection.reset_pk_sequence!('users')
ActiveRecord::Base.connection.reset_pk_sequence!('orders')

u1 = User.create!(
  name: 'Alice',
  password: 'alice123',
  age: 25,
  admin: false
)

u2 = User.create!(
  name: 'Bob',
  password: 'bobsecure',
  age: 30,
  admin: false
)

u3 = User.create!(
  name: 'Admin',
  password: 'adminpass',
  age: 34,
  admin: true
)

u4 = User.create!(
  name: 'Eve',
  password: 'secret',
  age: 42,
  admin: false
)

u5 = User.create!(
  name: 'Mallory',
  password: 'mal123',
  age: 38,
  admin: false
)

puts "Utworzono #{User.count} użytkowników."

puts 'Tworzenie zamówień dla każdego użytkownika...'

# Dodajmy parę przykładowych zamówień
[u1, u2, u3, u4].each do |user|
  2.times do
    Order.create!(
      user: user,
      total: rand(10..300) # Losowa kwota 10..300
    )
  end
end

puts "Utworzono #{Order.count} zamówień."
