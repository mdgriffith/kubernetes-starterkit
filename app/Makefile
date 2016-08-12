
setup: build-nginx build-letsencrypt build-api-dependencies build-api

build: build-nginx build-api

build-nginx:
	(cd nginx;\
	eval "docker build -t $(STARTERKIT_IMAGE_REPO)nginx-static-proxy:$(STARTERKIT_CURRENT_VERSION) .";)

build-letsencrypt:
	(cd letsencrypt;\
	eval "docker build -t $(STARTERKIT_IMAGE_REPO)letsencrypt-companion:$(STARTERKIT_CURRENT_VERSION) .";)

build-api:
	(cd api; cp docker/dev.Dockerfile Dockerfile;\
	eval "docker build -t $(STARTERKIT_IMAGE_REPO)flask-api:$(STARTERKIT_CURRENT_VERSION) .";\
	rm Dockerfile)

build-api-dependencies:
	(cd api; cp docker/dependencies.Dockerfile Dockerfile; docker build -t python-dependencies:3.5 .; rm Dockerfile)

print-vars:
	(echo $(STARTERKIT_CURRENT_VERSION))
	(echo $(STARTERKIT_IMAGE_REPO))
	(echo $(DOCKER_HOST))
	(echo "$(STARTERKIT_IMAGE_REPO)api:$(STARTERKIT_CURRENT_VERSION)")

push-gcloud:
	(eval "gcloud docker push $(STARTERKIT_IMAGE_REPO)flask-api:$(STARTERKIT_CURRENT_VERSION)")
	(eval "gcloud docker push $(STARTERKIT_IMAGE_REPO)nginx-static-proxy:$(STARTERKIT_CURRENT_VERSION)")
