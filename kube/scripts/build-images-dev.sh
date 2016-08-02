
# Set docker so that it's looking at docker in minikube.
eval $(minikube docker-env)

# Build Python dependencies image
cd app/api/
cp docker/dependencies.Dockerfile Dockerfile
docker build -t python-dependencies:2.7 .
rm Dockerfile

# Build API image
cp docker/dev.Dockerfile Dockerfile
docker build -t flask-api:dev .
rm Dockerfile
cd ../..

# Build Nginx
cd app/nginx/
docker build -t nginx-static-proxy:latest .
cd ../..
