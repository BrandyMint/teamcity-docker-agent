all: clean GeoLiteCity.dat prebuild build push

GeoLiteCity.dat:
	(test -f /usr/share/GeoIP/GeoLiteCity.dat && cp /usr/share/GeoIP/GeoLiteCity.dat .) || echo 'No GEO Lite city'

clean:
	rm -fr ./dist

full_clean:
	rm -f ./buildAgent.zip
	rm -fr ./dist

buildAgent.zip:
	wget http://teamcity.brandymint.ru/update/buildAgent.zip

prebuild: buildAgent.zip
	mkdir ./dist
	unzip buildAgent.zip -d dist/buildagent
	mv dist/buildagent/conf dist/buildagent/conf_dist

build:
	docker build -t teamcity-android-agent .

push:
	docker tag teamcity-android-agent brandymint/teamcity-android-agent
	docker push brandymint/teamcity-android-agent

test: prebuild
	./scripts/docker/build
