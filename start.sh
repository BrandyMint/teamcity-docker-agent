#!/usr/bin/env bash

docker run -it -e SERVER_URL=teamcity.brandymint.ru \
  --name=agent1
  --restart=always
  -v /opt/teamcity_agent_conf:/data/teamcity_agent/conf \
  -v /var/run/postgresql/:/var/run/postgresql/ \
  -e AGENT_NAME=agent1 \
  brandhmint/teamcity-agent
