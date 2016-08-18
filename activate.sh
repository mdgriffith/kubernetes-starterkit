
if [ ! -d "env" ]; then
  virtualenv env
fi
source env/bin/activate
pip install --editable .
minikube start