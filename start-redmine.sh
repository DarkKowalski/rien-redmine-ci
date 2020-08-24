#!/bin/sh
# run rake test
cd /rien-test/compiled-redmine && rake test
ret=$?
if [$ret -ne 0]; then
    echo "rake test failed"
    exit $ret
fi

## setup compiled redmine
cd /rien-test/compiled-redmine \
  && bundle exec rake generate_secret_token \
  && RAILS_ENV=production bundle exec rake db:migrate \
  && RAILS_ENV=production REDMINE_LANG=en bundle exec rake redmine:load_default_data \
  && bundle exec rails server webrick -e production