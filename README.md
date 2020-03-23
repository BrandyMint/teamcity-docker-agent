# Это docker-контейнер с агентом для teamcity, в который установлено rbenv, nvm, php, jvm, android sdk

## Установка и запуск

Какаем контейнер
                                     
`docker pull brandymint/teamcity-android-agent`

Старт

```
docker run -it -e SERVER_URL=CI_SERVER_HOST \
  -e AGENT_NAME=agent1 \
  -v /opt/teamcity_agent_conf:/date/teamcity_agent/conf \
  -v /var/run/postgresql:/var/run/postgresql \
  -v /var/run/mysqld/mysqld.sock:/var/run/mysqld/mysqld.sock \
  brandymint/teamcity-android-agent
```

Где:

* `CI_SERVER_HOST` - ваш teamcity-сервер.
* `agent1` - название агента.
* `/opt/teamcity_agent_conf` - то, куда на хостовой машине агент будет складывать свой конфиг. На маках лучше держать это где-то в домашке.

Параметры `/var/run/postgresql` и `/var/run/mysqld/mysqld.sock` указывать не нужно, если на хостовой машине нет этих серверов.
