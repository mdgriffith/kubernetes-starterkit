# Apply the kubernetes files with touching the images.

user=$1
version="$(git describe --abbrev=0 --tags)"

sed "s|{{USER}}|$user|;s|{{VERSION}}|$version|" kube/environments/prod/templates/deployments-template.yaml > kube/environments/prod/deployments.yaml

kubectl apply -f kube/environments/prod/deployments.yaml
kubectl apply -f kube/environments/prod/database.yaml
kubectl apply -f kube/environments/prod/services.yaml
