FROM jetbrains/teamcity-minimal-agent:latest

MAINTAINER Danil Pismenny <danil@brandymint.com>

# Base

RUN locale-gen en_US.UTF-8

ENV HOME /root
ENV SHELL /bin/bash
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update -q \
  && apt-get -q -y install git curl less vim-tiny autoconf bison build-essential libpq-dev libssl-dev libyaml-dev libreadline6-dev zlib1g-dev

# Ruby

ENV PATH $HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
ENV RUBY_VERSION 2.2.5

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
  rbenv install $RUBY_VERSION && \
  rbenv global $RUBY_VERSION

RUN gem install --no-ri --no-rdoc bundler
RUN rbenv rehash

# RUN 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> $HOME/.profile
RUN echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc

COPY .gemrc /root/.gemrc

# NVM

ENV PATH $HOME/.nvm/bin:$PATH

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash

RUN /bin/bash -c "echo \"[[ -s \$HOME/.nvm/nvm.sh ]] && . \$HOME/.nvm/nvm.sh\" >> /etc/profile.d/npm.sh" \
  && echo "[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh" >> $HOME/.bashrc

ENV NVM_DIR $HOME/.nvm"

# ENV NODE_VERSION stable
ENV SHIPPABLE_NODE_VERSION=v5.0.0

RUN . $HOME/.nvm/nvm.sh && \
  nvm install $SHIPPABLE_NODE_VERSION && \
  nvm alias default $SHIPPABLE_NODE_VERSION && \
  nvm use default && \
  npm install bower gulp babel-cli -g --allow-root


# Clear all
RUN apt-get purge -y -q autoconf bison build-essential libssl-dev zlib1g-dev \
  && apt-get autoremove -y

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
