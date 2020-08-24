FROM ruby:2.7.1-buster

# install essential packages
RUN apt update -y && apt upgrade -y
RUN apt install -y build-essential git postgresql
RUN apt autoclean

# clone redmine
RUN mkdir -p /rien-test/rien \
    && cd /rien-test \
    && git clone https://github.com/redmine/redmine \
    && cd /rien-test/redmine \
    && sed -i '/^ruby.*/d' Gemfile \
    && echo "gem 'rien', path: '/rien-test/rien/.'" >> Gemfile
## FIXME: use safe methods for these
## remove ruby '>= 2.3.0', '< 2.7.0'
## add gem rien

# add db config and Rienfile
COPY ./database.yml /rien-test/redmine/config/database.yml
COPY ./Rienfile /rien-test/redmine/Rienfile

# build and install rien
## apps->test->root
COPY ./rien/bin/          /rien-test/rien/bin
COPY ./rien/lib/          /rien-test/rien/lib
COPY ./rien/Gemfile      /rien-test/rien/Gemfile
COPY ./rien/rien.gemspec /rien-test/rien/rien.gemspec
RUN cd /rien-test/rien \
    && bundle \
    && gem build ./rien.gemspec \
    && gem install --local rien-*.gem

## probe
RUN rien --help

# encode redmine
RUN cd /rien-test && rien -p redmine -u

# setup redmine
RUN cd /rien-test/compiled-redmine \
    && bundle
COPY ./start-redmine.sh /rien-test/start-redmine.sh

# entry
ENTRYPOINT [ "/rien-test/start-redmine.sh" ]
