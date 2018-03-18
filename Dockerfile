# FROM jetbrains/teamcity-minimal-agent:latest
FROM ubuntu:latest

MAINTAINER Danil Pismenny <danil@brandymint.com>

# Base

RUN apt-get clean \
  && apt-get update \ 
  && apt-get install -q -y locales apt-utils git curl less vim-tiny autoconf bison build-essential \
     libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libmagickwand-dev imagemagick sqlite3 libsqlite3-dev telnet apt-transport-https

RUN locale-gen en_US.UTF-8

ENV HOME /root
ENV SHELL /bin/bash
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8


# Update to postgresql-9.5

RUN apt-get -q -y install wget lsb-release
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -

RUN apt-get update -q && apt-get -q -y install postgresql-client libpq-dev
 

# mysql-client

RUN apt-get -q -y install libmysqlclient-dev

#
# Install yarn
#

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -q \
  && apt-get install --no-install-recommends yarn

#
# PHP and composer
#

RUN apt-get install -q -y php-cli composer

#
# GeoLiteCity
#

RUN wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
 && gunzip GeoLiteCity.dat.gz \
 && mkdir /usr/share/GeoIP \
 && mv GeoLiteCity.dat /usr/share/GeoIP/GeoLiteCity.dat

#
# Ruby
#

ENV PATH $HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
ENV RUBY_VERSION 2.4.3

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
  rbenv install $RUBY_VERSION && \
  rbenv global $RUBY_VERSION

RUN gem install --no-ri --no-rdoc bundler json pg
RUN rbenv rehash

# RUN 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> $HOME/.profile
RUN echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc

COPY .gemrc /root/.gemrc

#
# NVM
#

ENV PATH $HOME/.nvm/bin:$PATH

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash

RUN /bin/bash -c "echo \"[[ -s \$HOME/.nvm/nvm.sh ]] && . \$HOME/.nvm/nvm.sh\" >> /etc/profile.d/npm.sh" \
  && echo "[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh" >> $HOME/.bashrc \
  && echo "[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh" >> $HOME/.profile

ENV NVM_DIR "$HOME/.nvm"

# ENV NODE_VERSION stable
ENV SHIPPABLE_NODE_VERSION=v8.9.4

RUN . $HOME/.nvm/nvm.sh && \
  nvm install $SHIPPABLE_NODE_VERSION && \
  nvm alias default $SHIPPABLE_NODE_VERSION && \
  nvm use default && \
  npm install bower gulp babel-cli -g --allow-root


# Clear all
# RUN apt-get purge -y -q autoconf bison build-essential libssl-dev zlib1g-dev && apt-get autoremove -y
# RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
