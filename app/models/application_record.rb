class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Comment to run in `development` mode or leave as is to run with docker-compose
  connects_to database: {
    writing: :primary,
    reading: :primary_replica
  }
end
