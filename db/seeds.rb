# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
user = User.create!(email: 'dean@example.com',
                    password: 'password',
                    password_confirmation: 'password')
user = User.create!(email: 'john@doe.com',
                    password: 'password',
                    password_confirmation: 'password')
user = User.create!(email: 'jane@doe.com',
                    password: 'password',
                    password_confirmation: 'password')

10.times do
  user = User.create!(email: Faker::Internet.email,
                      password: 'password',
                      password_confirmation: 'password')
end
