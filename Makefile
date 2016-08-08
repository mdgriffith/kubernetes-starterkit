
setup-dev: start-dev focus-dev build-dev create-database-credentials create-session-secret refresh-dev

# Start up minikube for local development
# and tell kubectl to focus on minikube.
start-dev:
	minikube start

focus-dev:
	kubectl config use-context minikube

# Build the docker images inside of minikube.
build-dev: focus-dev
	(source kube/scripts/deployment-envs/set-dev-env.sh;\
	 cd app; make setup)

# Apply dev kubernetes environment
refresh-dev: focus-dev
	sh kube/scripts/refresh-dev.sh

# ------------- The following commands only apply to Production ----------------

test-var:
	(source kube/scripts/deployment-envs/set-dev-env.sh; cd app; make print-vars)

setup-prod: focus-prod create-database-credentials create-session-secret deploy

focus-prod:
	echo "Whoops, this hasn't been set up yet."
	echo "Edit the deploy section of the Makefile."
	echo "Set a google container engine user name, and a google context to deploy to."
	# kubectl config use-context context_to_deploy_to

# Builds images with correct tags and applies the kube config files.
# First create the environment we want, then build
deploy:
	(source kube/scripts/deployment-envs/set-google-env.sh;\
	 source $$(kube/scripts/deployment-envs/utils/set-version.sh);\
	 cd app; make print-vars;)
	#  cd app; make build; make push-gcloud;)#source kube/scripts/set-version.sh;\


refresh-prod: focus-prod
	echo "Not Implemented Yet!"
	# sh kube/scripts/refresh-prod.sh google_user_name

# Request an ssl certificate from letsencrypt
request-ssl: focus-prod
	echo "Not Implemented Yet!"

# Create a cronjob to request an ssl certificate every month.
request-ssl-monthly: focus-prod
	echo "Not Implemented Yet!"

# Report the current status of the ssl certificate.
# Statuses include:
#  * No Certificate
#  * Valid Certificate Present
#  * Valid Certificate Present, Renewal scheduled on XYZ
ssl-status: focus-prod
	echo "Not Implemented Yet!"

# ------------- The following apply to any environment ----------------

create-database-credentials:
	sh kube/scripts/create-database-credentials.sh

create-session-secret:
	sh kube/scripts/create-session-secret.sh
