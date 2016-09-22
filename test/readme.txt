TESTING README

Before launching integration tests, it is necessary to populate
the testing database with enough records. This is done using the
below command:

bundle exec rake db:reset RAILS_ENV=test

Note that the records will be persisted even after the tests are
done. This is convenient for testing as the seeding process is
quite lengthy. All integration tests performed afterwards will
rely on that same database.


Checks whether there are any pending migrations
rake db:test:prepare



bundle exec rake db:drop RAILS_ENV=test db:test:prepare

