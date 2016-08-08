eval $(minikube docker-env);
export STARTERKIT_IMAGE_REPO=gcr.io/lunar-alpha-93213/;
export STARTERKIT_CURRENT_VERSION=latest;
source kube/scripts/deployment-envs/utils/set-version.sh
