# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# link ActionMailer to sendgrid.
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
   :tls => true,
   :address => "smtp.gmail.com",
   :port => 587,
   :domain => "gmail.com",
   :authentication => :login,
 }

 ActionMailer::Base.smtp_settings = {
   :user_name => ENV['SENDGRID_USERNAME'],
   :password => ENV['SENDGRID_PASSWORD'],
   :domain => 'https://forestsat-demo.herokuapp.com/',
   :address => 'smtp.sendgrid.net',
   :port => 587,
   # :authentication => :login,
   :authentication => :plain,
   :enable_starttls_auto => true
 }
