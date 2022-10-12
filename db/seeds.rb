roles = %w[user admin]
roles.each { |role| Role.create(name: role) }

admin =
  User.create!(
    first_name: 'admin',
    last_name: 'admin',
    email: 'admin@email.com',
    password: "#{Rails.application.credentials.users.admin_password}"
  )
admin.roles << Role.find(2)
admin.update(email_verified: true)
admin.update(trade_verified: true)

verified =
  User.create!(
    first_name: 'verified',
    last_name: 'verified',
    email: 'verified@email.com',
    password: "#{Rails.application.credentials.users.verified_password}"
  )
verified.roles << Role.find(1)
verified.update(email_verified: true)
verified.update(trade_verified: true)

email_verified =
  User.create!(
    first_name: 'email_verified',
    last_name: 'email_verified',
    email: 'email_verified@email.com',
    password: "#{Rails.application.credentials.users.email_verified_password}"
  )
email_verified.roles << Role.find(1)
email_verified.update(email_verified: true)
