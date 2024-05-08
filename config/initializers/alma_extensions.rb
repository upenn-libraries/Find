# frozen_string_literal: true

# In order to implement all the functionality needed for this application we had to make multiple extensions to the
# Alma gem. Our hope is that we will be able to submit these additions to the Alma gem after launch.

# Require all Ruby files in the alma_extensions directory to include our additions.
Dir[Rails.root.join('lib/alma_extensions/*.rb')].each { |f| require f }
