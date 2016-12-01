#!/usr/bin/env bash

docker run -it -e SERVER_URL=teamcity.brandymint.ru \
  -v /opt/teamcity_agent_conf:/data/teamcity_agent/conf \
  -v /var/run/postgresql/:/var/run/postgresql/ \
  -e AGENT_NAME=srv2-agent1-v1 \
  dapi/teamcity-agent
