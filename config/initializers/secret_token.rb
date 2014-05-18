# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
#Webappmini::Application.config.secret_token = 'blah'



secret_file = File.join(Rails.root, "bi_secret")
if File.exist?(secret_file)
  secret = File.read(secret_file)
else
  secret = SecureRandom.hex(64)
  File.open(secret_file, 'w') { |f| f.write(secret) }
end
  
Webappmini::Application.config.secret_token = secret
