
setup: build-nginx build-api-dependencies build-api

build: build-nginx build-api

build-nginx:
	(cd nginx; docker build -t nginx-static-proxy:latest .)

build-api:
	(cd api; cp docker/dev.Dockerfile Dockerfile; docker build -t flask-api:dev .; rm Dockerfile)

build-api-dependencies:
	(cd api; cp docker/dependencies.Dockerfile Dockerfile; docker build -t python-dependencies:3.5 .; rm Dockerfile)

print-vars:
	(echo $(STARTERKIT_VERSION))
	(echo $(IMAGE_PREFIX))
	(echo $(DOCKER_HOST))
	(echo "api:$(STARTERKIT_VERSION)")
