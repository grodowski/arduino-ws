User.destroy_all
test = User.new(email: 'test@example.com', password: 'qweqweqwe', password_confirmation: 'qweqweqwe')
test.save