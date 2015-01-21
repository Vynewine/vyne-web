## README

### Step 1:
Make sore you have these installed.
Ruby 2.1.2
Rails 4.1.4
Heroku Toolbelt

### Step 2:
Clone this repository

### Step 3:
This system uses PostgreSQL.
* Download PostgresApp from here: (http://postgresapp.com)
* Start 'psql'
* Create user and database for vyne:
```
CREATE USER vyne WITH PASSWORD 'Valpolicella';
ALTER USER vyne SUPERUSER;
CREATE DATABASE vyne_development WITH OWNER = vyne;
```

### Step 4:
We are using Redis and Resque for Jobs
#### Install Redis
```
brew install redis
```
Follow the instructions in the notes to start Redis on boot, or start it manually with redis-server

Test if Redis is working
```
redis-cli ping
```
Should respond with PONG

### Step 4:
* Browse to vyne dir using the console and start it up:
```
bundle install
rake db:drop && rake db:create (drop if already existent)
rake db:migrate
rake db:seed
rake sunspot:solr:start (only if you didn't start before)
rake sunspot:reindex
foreman start
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
RAILS_ENV=production rake assets:clean assets:precompile
```

Commit precompiled assets
```
git add .
git commit -a -m "Adding precompiled assets"
```

Push to Heroku (assuming you are logged in to Vyne Heroku account)
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

