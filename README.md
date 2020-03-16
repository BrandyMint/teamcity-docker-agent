## Docker контейнер для тестирования приложений на ruby, php с доступом mysql, postgresql, а также android studio

[![Build Status](https://travis-ci.org/BrandyMint/teamcity-docker-agent.svg?branch=master)](https://travis-ci.org/BrandyMint/teamcity-docker-agent)

## Создание образа

> make

## TeamCity Minimal Agent Image Dockerfile

This project contains the Dockerfile and all necessary scripts to build the Docker image and run a TeamCity Build Agent inside the container.

You can pull the ready-to-use image from the Docker Hub repository
                                     
`docker pull brandymint/teamcity-agent`

sources: https://github.com/JetBrains/teamcity-docker-minimal-agent

# Start container example:

```
docker run -it -e SERVER_URL=teamcity.brandymint.ru \
  -v /opt/teamcity_agent_conf:/date/teamcity_agent/conf \
  -v /var/run/postgresql:/var/run/postgresql \
  -e AGENT_NAME=agent1 \
  brandymint/teamcity-agent
```

If you need to build your own image, you need to perform the following:

1) Pull our base image and re-tag it 
```
docker pull jetbrains/teamcity-base
docker tag jetbrains/teamcity-base teamcity-base
```
You can use your own base image with the operation system of your choice and JAVA installed. TeamCity relies on the `JRE_HOME` environment variable. Just tag your own image with the `teamcity-base` tag.

2) Extract buildAgent.zip of any version you'd like to use into  the `dist/buildagent` folder and prepare agent config directory. In the same directory where the Dockerfile is placed, run
```
./prebuild.sh
```

3) Run the `docker build` command:
```
docker build -t teamcity-agent
```

See our [detailed instructions] (https://hub.docker.com/r/brandymint/teamcity-agent/) on how to use the image in the Docker Hub repository .

4) Push to docker hub

```
docker tag IMAGE brandymint/teamcity-agent
docker push brandymint/teamcity-agent
```
