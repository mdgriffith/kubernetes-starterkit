
setup-dev: start-dev build-dev database-credentials session-secret apply-dev

# Build the docker images inside of minikube.
# Can be used to rebuild if image is failing.
build-dev:
	sh kube/scripts/build-images-dev.sh

# Start up minikube for local development
# and tell kubectl to focus on minikube.
start-dev:
	minikube start
	kubectl config use-context minikube

# Apply dev kubernetes environment
apply-dev:
	sh kube/scripts/apply-dev.sh

stream-logs-dev:
	echo "not implemented"

inspect-db-dev:
	echo "not implemented"

deploy:
	echo "Whoops, this hasn't been set up yet."
	echo "Edit the deploy section of the Makefile."
	echo "Set a google container engine user name, and a google context to deploy to."
	# sh kube/scripts/deploy.sh google_user_name context_to_deploy_to

database-credentials:
	sh kube/scripts/create-database-credentials.sh

session-secret:
	sh kube/scripts/create-session-secret.sh
