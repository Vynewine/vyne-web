#! /bin/bash
rake sunspot:solr:stop
rake sunspot:solr:start
rake db:drop && rake db:create
rake db:migrate
rake db:seed
rake sunspot:reindex