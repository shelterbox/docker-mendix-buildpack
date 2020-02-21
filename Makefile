get-sample:
	if [ -d build ]; then rm -rf build; fi
	if [ -d downloads ]; then rm -rf downloads; fi
	mkdir -p downloads build
	wget https://s3-eu-west-1.amazonaws.com/mx-buildpack-ci/BuildpackTestApp-mx-7-16.mda -O downloads/application.mpk
	unzip downloads/application.mpk -d build/

svn-checkout: 
	@ \
	if [ -n "$$appbranch" ]; \
	then \
	  branch="branches/$$appbranch"; \
	else \
	  branch='trunk'; \
	fi; \
	echo "Getting source from branch: $$branch..."; \
	if [ -n "$$appid" ]; \
	then \
	  if [ -d build ]; then rm -rf build; fi; \
	  if [ -d downloads ]; then rm -rf downloads; fi; \
	  mkdir -p build; \
	  svn checkout https://teamserver.sprintr.com/$$appid/$$branch ./build/; \
	else \
	  echo "\$appid variable is not set!"; \
	  echo "To set the variable, use:"; \
	  echo "    export appid='22d1a46a-5602-11e9-8624-00155d0f460b'"; \
	fi

build-image: 
	@ \
	if [ -n "$$appname" ]; \
	then \
	  apprev=$$(svn info --show-item revision ./build); \
	  echo "Building image for $$appname (revision $$apprev)..."; \
	  docker build \
	    --build-arg BUILD_PATH=build \
	    -t shelterbox/$$appname:$$apprev .; \
	else \
	  echo "Please set \$$appname to a valid name."; \
	  echo "To set the variable, use:"; \
	  echo "    export appname='MyApp'"; \
	fi

test-container:
	tests/test-generic.sh tests/docker-compose-postgres.yml
	tests/test-generic.sh tests/docker-compose-sqlserver.yml
	tests/test-generic.sh tests/docker-compose-azuresql.yml

run-container:
	docker-compose -f tests/docker-compose-mysql.yml up
