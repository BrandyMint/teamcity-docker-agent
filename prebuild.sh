wget http://teamcity.bang8.ru/update/buildAgent.zip
mkdir dist
unzip buildAgent.zip -d dist/buildagent
mv dist/buildagent/conf dist/buildagent/conf_dist
