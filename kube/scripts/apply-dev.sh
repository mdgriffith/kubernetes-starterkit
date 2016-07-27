# Apply Development Kubenertes environment.


sed "s|{{REPLACE_ME_WITH_LOCAL_PATH}}|$PWD/app/|" kube/environments/dev/templates/deployments-template.yaml > kube/environments/dev/deployments.yaml

kubectl apply -f kube/environments/dev/deployments.yaml

kubectl apply -f kube/environments/dev/services.yaml
