eval $(minikube docker-env);
export STARTERKIT_IMAGE_REPO=gcr.io/my-google-project/;
export STARTERKIT_CURRENT_VERSION=latest;
eval $(kube/scripts/deployment-envs/utils/set-version.sh);
