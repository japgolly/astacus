# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_astacus_session',
  :secret      => '34f87afb87577f828fb0c98bd92141ff1200ba65181a62de8bdf9f6a92e83384fb50a0a211e60736c51e698e463a558f50e1be9592295c0a223b39c9fb6e0377'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
