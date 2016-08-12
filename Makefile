
setup-dev: start-dev build-dev create-dev-secrets refresh-dev

# Start up minikube for local development
# and tell kubectl to focus on minikube.
start-dev:
	minikube start

create-dev-secrets:
	(source kube/scripts/deployment-envs/set-dev-env.sh;\
	 sh kube/scripts/create-database-credentials.sh;\
	 sh kube/scripts/create-session-secret.sh;)

# Build the docker images inside of minikube.
build-dev:
	(source kube/scripts/deployment-envs/set-dev-env.sh;\
	 sed "s|{{REPLACE_ME_WITH_LOCAL_PATH}}|$PWD|" kube/environments/dev/templates/deployments-template.yaml > kube/environments/dev/deployments.yaml;\
	 cd app; make setup;)

# Apply dev kubernetes environment
refresh-dev:
	(source kube/scripts/deployment-envs/set-dev-env.sh;\
	 kubectl apply -f kube/environments/dev/deployments.yaml;\
	 kubectl apply -f kube/environments/dev/services.yaml;)

# ------------- The following commands only apply to Production ----------------

setup-prod: create-prod-secrets deploy

create-prod-secrets:
	(source kube/scripts/deployment-envs/set-google-env.sh;\
	 sh kube/scripts/create-database-credentials.sh;\
	 sh kube/scripts/create-session-secret.sh;)

# Builds images with correct tags and applies the kube config files.
deploy:
	(source kube/scripts/deployment-envs/set-google-env.sh;\
	 source kube/scripts/deployment-envs/utils/set-version.sh;\
	 cd app; make build; make push-gcloud;\
	 cd kube/environments/prod/;\
	 sed "s|{{IMAGE_REPO}}|$STARTERKIT_IMAGE_REPO|;s|{{CURRENT_VERSION}}|$STARTERKIT_CURRENT_VERSION|" templates/deployments-template.yaml > deployments.yaml;\
	 cd ../../../;\
	 kubectl apply -f kube/environments/prod/deployments.yaml;\
	 kubectl apply -f kube/environments/prod/database.yaml;\
	 kubectl apply -f kube/environments/prod/services.yaml;)

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
ssl-status:
	echo "Not Implemented Yet!"
