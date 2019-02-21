wget http://teamcity.brandymint.ru/update/buildAgent.zip
mkdir dist
unzip buildAgent.zip -d dist/buildagent
mv dist/buildagent/conf dist/buildagent/conf_dist
