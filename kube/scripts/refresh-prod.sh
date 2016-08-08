
user=$STARTERKIT_IMAGE_REPO
version=$STARTERKIT_CURRENT_VERSION

sed "s|{{USER}}|$user|;s|{{VERSION}}|$version|" kube/environments/prod/templates/deployments-template.yaml > kube/environments/prod/deployments.yaml

kubectl apply -f kube/environments/prod/deployments.yaml
kubectl apply -f kube/environments/prod/database.yaml
kubectl apply -f kube/environments/prod/services.yaml
