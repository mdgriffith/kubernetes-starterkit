# Kubernetes StarterKit
A basic Kubernetes setup for local development and deployment to google cloud

## Prerequisites
  * Clone this repo to a local dir.
  * Install [kubectl](http://kubernetes.io/docs/user-guide/prereqs/)
    _A command line utility for managing a kubernetes cluster_
  * Install [minikube](https://github.com/kubernetes/minikube)
    _Run kubernetes locally_
  * Install [Google Cloud SDK](https://cloud.google.com/sdk/)
    (If you want to deploy to google)


## Developing locally

We'll develop locally using `minikube` to run Kubernetes in a local virtual machine.

In the base directory, run `make setup-dev`.  This will install the app in the locally running kubernetes.

You can now edit the python code in the `app` folder and it will automatically be reloaded on save.

Some Useful Commands

Command                | Description
------------------------------------------
`minikube ip`          | See the Ip that minikube is running on locally.
`minikube stop`        | Stop the minikube (does not delete app)
`minikube dashboard`   | Get the address of the Kubernetes Dashboard for local.
`make dev-logs`        | View the logs of our app


### TODO
  * Inspect database
  * Run database migration

## Deploying To Google Container Engine
