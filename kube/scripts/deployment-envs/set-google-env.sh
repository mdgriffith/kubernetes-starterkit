kubectl config use-context GOOGLECONTEXT
eval $(minikube docker-env);
export STARTERKIT_IMAGE_REPO=gcr.io/GOOGLEPROJECT/;
export STARTERKIT_CURRENT_VERSION=latest;
