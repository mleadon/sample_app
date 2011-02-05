# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                  "Michael Leadon"
  user.email                 "mhartl@cirm.ca.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
end

