# FROM jetbrains/teamcity-minimal-agent:latest
FROM adoptopenjdk/openjdk8:latest

MAINTAINER Danil Pismenny <danil@brandymint.com>

# Base

RUN apt-get clean \
  && apt-get update \ 
  && apt-get install -q -y locales apt-utils git curl less vim-tiny autoconf bison build-essential \
     libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libmagickwand-dev imagemagick sqlite3 libsqlite3-dev telnet apt-transport-https

RUN locale-gen en_US.UTF-8 

# timezone data
RUN ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
  && apt-get -q install -y tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata

ENV HOME /root
ENV SHELL /bin/bash
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install JVM (for teamcity-agent)

RUN apt-get -q -y install default-jre default-jdk

# redis-server

RUN apt-get -q -y install redis-server

# Update to postgresql-9.5

RUN apt-get -q -y install wget lsb-release \
  && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list' \
  && wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add - \
  && apt-get update -q \
  && apt-get -q -y install postgresql-client libpq-dev


# mysql-client

RUN apt-get -q -y install libmysqlclient-dev mysql-client

#
# Install yarn
#

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update -q \
  && apt-get install --no-install-recommends yarn


#
# Ruby
#

ENV PATH $HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
ENV RUBY_VERSION 2.6.5

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
  && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
  && rbenv install $RUBY_VERSION \
  && rbenv global $RUBY_VERSION \
  && gem install bundler json pg \
  && rbenv rehash

RUN echo 'eval "$(rbenv init -)"' >> $HOME/.profile \
  && echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc

COPY .gemrc /root/.gemrc

#
# PHP and composer
#

# RUN apt-get install -q -y php-cli composer php-mbstring php-bcmath php-gd php-curl php-xml php-zip php-json php-cli php-mysql php-mcrypt php-fpm

# Phalcon
# RUN apt-get remove -q php
# RUN curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | bash
# RUN apt-get update -q
# RUN apt-get install php7.0-phalcon

#
# GeoLiteCity
#

# RUN mkdir /usr/share/GeoIP
# COPY GeoLiteCity.dat /usr/share/GeoIP/

#
# ANDROID STUDIO
#
# Source https://github.com/saschpe/docker-android-sdk/blob/master/Dockerfile

ARG android_api=29
ARG android_build_tools=29.0.2

LABEL description="Android SDK ${android_api} with build-tools ${android_build_tools}"

ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME $ANDROID_SDK_ROOT
ENV GLIBC 2.25-r0
ENV PATH $PATH:$ANDROID_SDK_ROOT/tools/bin

RUN apt-get install unzip \
    && wget --quiet https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O /tmp/tools.zip \
    && mkdir -p $ANDROID_SDK_ROOT \
    && unzip -q /tmp/tools.zip -d $ANDROID_SDK_ROOT \
    && rm -v /tmp/tools.zip \
    && mkdir -p /root/.android/ \
    && touch /root/.android/repositories.cfg
RUN yes | sdkmanager \
        "build-tools;${android_build_tools}" \
        "platforms;android-${android_api}" >/dev/null \
    && rm -rf  \
        # Delete proguard docs and examples
        $ANDROID_SDK_ROOT/tools/proguard/examples \
        $ANDROID_SDK_ROOT/tools/proguard/docs \
    && sdkmanager --list | sed -e '/Available Packages/q'

#
# NVM
#

ENV PATH $HOME/.nvm/bin:$PATH

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash

RUN /bin/bash -c "echo \"[[ -s \$HOME/.nvm/nvm.sh ]] && . \$HOME/.nvm/nvm.sh\" >> /etc/profile.d/npm.sh" \
  && echo "[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh" >> $HOME/.bashrc \
  && echo "[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh" >> $HOME/.profile

ENV NVM_DIR "$HOME/.nvm"

ENV SHIPPABLE_NODE_VERSION=v10.16.3

RUN . $HOME/.nvm/nvm.sh && \
  nvm install $SHIPPABLE_NODE_VERSION && \
  nvm alias default $SHIPPABLE_NODE_VERSION && \
  nvm use default


#
# Собственно teamcity-agent
# Отсюда: https://github.com/JetBrains/teamcity-docker-minimal-agent/blob/master/ubuntu/Dockerfile
#

VOLUME /data/teamcity_agent/conf
ENV CONFIG_FILE /data/teamcity_agent/conf/buildAgent.properties
LABEL dockerImage.teamcity.version="latest" \
      dockerImage.teamcity.buildNumber="latest"

COPY run-agent.sh /run-agent.sh
COPY run-services.sh /run-services.sh
COPY dist/buildagent /opt/buildagent

RUN useradd -m buildagent && \
    chmod +x /run-agent.sh /run-services.sh && sync

CMD ["/run-services.sh"]

EXPOSE 9090

# Clear all
# RUN apt-get purge -y -q autoconf bison build-essential libssl-dev zlib1g-dev && apt-get autoremove -y
# RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
