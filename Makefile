all: clean prebuild build push

clean:
	rm -f ./buildAgent.zip
	rm -fr ./dist

prebuild:
	wget http://teamcity.bang8.ru/update/buildAgent.zip
	mkdir ./dist
	unzip buildAgent.zip -d dist/buildagent
	mv dist/buildagent/conf dist/buildagent/conf_dist

build:
	docker build -t teamcity-agent .

push:
	docker tag teamcity-agent brandymint/teamcity-agent
	docker push brandymint/teamcity-agent
