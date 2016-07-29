#
# Basic deployment.  Rebuilds image, pushes image and updates deployment.
#
user=$1

# There are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "There are uncommitted changes.  Commit them and run deploy again."
    exit 1
fi

echo -n "Last version released was "
git describe --abbrev=0 --tags
echo "What version number should be used for this release? "
read version

if [[ -z "$version" ]]; then
   echo "Version can't be left blank, exiting without deploying."
   exit 1
fi

# Tags releases in github
git tag -a $version -m "$version release"
git push --tags

# Build and Push image
cd app/api/
cp docker/prod.Dockerfile Dockerfile
eval "docker build -t gcr.io/$user/flask-api:$version ."
eval "gcloud docker push gcr.io/$user/flask-api:$version"
rm Dockerfile

cd ../nginx
eval "docker build -t gcr.io/$user/nginx-proxy:$version ."
eval "gcloud docker push gcr.io/$user/nginx-proxy:$version"
cd ../..

# Add the new container version to the deployments file.
sed "s|{{USER}}|$user|;s|{{VERSION}}|$version|" kube/environments/prod/templates/deployments-template.yaml > kube/environments/prod/deployments.yaml

kubectl apply -f kube/environments/prod/deployments.yaml
kubectl apply -f kube/environments/prod/database.yaml
kubectl apply -f kube/environments/prod/services.yaml
