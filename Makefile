
setup-dev:
	(sed "s|{{REPLACE_ME_WITH_LOCAL_PATH}}|$PWD/app/|" kube/environments/dev/templates/deployments-template.yaml > kube/environments/dev/deployments.yaml)
	(minikube start)
	(kubectl config use-context minikube)
	build-dev
	database-credentials
	session-secret
	(kubectl apply -f kube/environments/dev/deployments.yaml)
	(kubectl apply -f kube/environments/prod/services.yaml)
	# Change name based on cluster name in compute console


build-dev:
	# Build Python dependencies image
	(cd app;cp docker/dependencies.Dockerfile Dockerfile;docker build -t python-dependencies:2.7 .;rm Dockerfile)
	# Build API image
	(cd app;cp docker/dev.Dockerfile Dockerfile;docker build -t flask-api:latest .;rm Dockerfile)

deploy:
	echo "Whoops, this hasn't been set up yet."
	echo "Edit the deploy section of the Makefile."
	echo "Set a google container engine user name, and a google context to deploy to."
	# sh kube/scripts/deploy.sh google_user_name context_to_deploy_to

database-credentials:
	sh kube/scripts/create-database-credentials.sh

session-secret:
	sh kube/scripts/create-session-secret.sh
