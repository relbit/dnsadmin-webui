# Load the rails application
require File.expand_path('../application', __FILE__)
require File.expand_path('../../app/api/dns_master_api', __FILE__)

# Initialize the rails application
DNSAdminGui::Application.initialize!
