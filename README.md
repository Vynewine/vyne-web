## README

### Step 1:
Have Ruby 2.1.2 and Rails 4.1.4 ready to go.

### Step 2:
Clone the repository

### Step 3:
This system uses PostgreSQL.
* Download PostgresApp from here: (http://postgresapp.com)
* Start 'psql'
* Create user and database for vyne:
```
CREATE USER vyne WITH PASSWORD 'Valpolicella';
ALTER USER vyne CREATEDB;
CREATE DATABASE vyne_development WITH OWNER = vyne;
```

### Step 4:
* Browse to vyne dir using the console and start it up:
```
bundle install
rake db:drop && rake db:create (drop if already existent)
rake db:migrate
rake db:seed
rake sunspot:solr:start (only if you didn't start before)
rake sunspot:reindex
rails s
```

### Testing
Create Test Database
```
RAILS_ENV=test rake db:drop db:create db:migrate
```

To run tests 
```
rake test
```

To run specific test file
```
rake test test/controllers/signup_controller_test.rb
```

To run specific test method 
```
ruby -I test test/controllers/signup_controller_test.rb -n /.*method name.*/
```

### Deployment
Precompile assets
```
RAILS_ENV=production rake assets:precompile
```

Commit precompiled assets
```
git add .
git commit -a -m "Adding precompiled assets"
```

Push to Heroku (assumin you are logged in to Vyne Heroku account)
```
git push heroku master
```

Push branch to Heroku:
```
git push heroku yourbranch:master
```

Run Migrations if required
```
heroku run rake --trace db:migrate
```

