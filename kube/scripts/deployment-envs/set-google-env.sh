kubectl config use-context context_to_deploy_to
eval $(minikube docker-env);
export STARTERKIT_IMAGE_REPO=gcr.io/my-google-project/;
export STARTERKIT_CURRENT_VERSION=latest;
