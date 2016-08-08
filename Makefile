
setup-dev: start-dev build-dev create-dev-secrets refresh-dev

# Start up minikube for local development
# and tell kubectl to focus on minikube.
start-dev:
	minikube start

create-dev-secrets:
	(source kube/scripts/deployment-envs/set-dev-env.sh;\
	 sh kube/scripts/create-database-credentials.sh;\
	 sh kube/scripts/create-session-secret.sh;
	 )

# Build the docker images inside of minikube.
build-dev:
	(source kube/scripts/deployment-envs/set-dev-env.sh;\
	 cd app; make setup; )

# Apply dev kubernetes environment
refresh-dev:
	sh kube/scripts/refresh-dev.sh

# ------------- The following commands only apply to Production ----------------

setup-prod: create-database-credentials create-session-secret deploy

create-prod-secrets:
	(source kube/scripts/deployment-envs/set-google-env.sh;\
	 sh kube/scripts/create-database-credentials.sh;\
	 sh kube/scripts/create-session-secret.sh;
	 )

# Builds images with correct tags and applies the kube config files.
deploy:
	(source kube/scripts/deployment-envs/set-google-env.sh;\
	 source kube/scripts/deployment-envs/utils/set-version.sh;\
	 cd app; make build; make push-gcloud; sh kube/scripts/refresh-prod.sh;)

# Request an ssl certificate from letsencrypt
request-ssl:
	echo "Not Implemented Yet!"

# Create a cronjob to request an ssl certificate every month.
request-ssl-monthly:
	echo "Not Implemented Yet!"

# Report the current status of the ssl certificate.
# Statuses include:
#  * No Certificate
#  * Valid Certificate Present
#  * Valid Certificate Present, Renewal scheduled on XYZ
ssl-status: focus-prod
	echo "Not Implemented Yet!"
