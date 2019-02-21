all: clean geoip prebuild build push

geoip:
	cp /usr/share/GeoIP/GeoLiteCity.dat .

clean:
	rm -f ./buildAgent.zip
	rm -fr ./dist

prebuild:
	wget http://teamcity.brandymint.ru/update/buildAgent.zip
	mkdir ./dist
	unzip buildAgent.zip -d dist/buildagent
	mv dist/buildagent/conf dist/buildagent/conf_dist

build:
	docker build -t teamcity-agent .

push:
	docker tag teamcity-agent brandymint/teamcity-agent
	docker push brandymint/teamcity-agent
