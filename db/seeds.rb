roles = %w[user admin]
roles.each { |role| Role.create(name: role) }

admin =
  User.create!(
    first_name: 'admin',
    last_name: 'admin',
    email: 'admin@email.com',
    password: "#{Rails.application.credentials.users.admin_password}"
  )
admin.roles << Role.find_by(name: 'admin')
admin.update(email_verified: true)
admin.update(trade_verified: true)

verified =
  User.create!(
    first_name: 'verified',
    last_name: 'verified',
    email: 'verified@email.com',
    password: "#{Rails.application.credentials.users.verified_password}"
  )
verified.roles << Role.find_by(name: 'user')
verified.update(email_verified: true)
verified.update(trade_verified: true)
verified.create_wallet(balance: 10000.00)

unverified =
  User.create!(
    first_name: 'unverified',
    last_name: 'unverified',
    email: 'unverified@email.com',
    password: "#{Rails.application.credentials.users.unverified_password}"
  )
unverified.roles << Role.find_by(name: 'user')
unverified.create_wallet(balance: 0)

email_verified =
  User.create!(
    first_name: 'email_verified',
    last_name: 'email_verified',
    email: 'email_verified@email.com',
    password: "#{Rails.application.credentials.users.email_verified_password}"
  )
email_verified.roles << Role.find_by(name: 'user')
email_verified.update(email_verified: true)
email_verified.create_wallet(balance: 10000.00)
