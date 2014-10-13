## README

### Step 1:
Have Ruby 2.1.2 and Rails 4.1.4 ready to go.

### Step 2:
Clone the repository

### Step 3:
This system uses PostgreSQL.
* Download PostgresApp from here: (http://postgresapp.com)
* Start 'psql'
* Create user and database for vynz:
```
CREATE USER vynz WITH PASSWORD 'Valpolicella';
ALTER USER vynz CREATEDB;
```

### Step 4:
* Browse to vynz dir using the console and start it up:
```
bundle install
rake db:drop && rake db:create (drop if already existent)
rake db:migrate
rake db:seed
rake sunspot:solr:start (only if you didn't start before)
rake sunspot:reindex
rails s
```