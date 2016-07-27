# Kubernetes StarterKit
A basic Kubernetes setup for local development and deployment to google cloud.  

It installs the following:
  * A basic Python Flask app
  * Nginx
  * A Postgres Database

## Prerequisites
  * Clone this repo to a local dir.
  * Install [kubectl](http://kubernetes.io/docs/user-guide/prereqs/)
    _A command line utility for managing a kubernetes cluster_
  * Install [minikube](https://github.com/kubernetes/minikube)
    _Run kubernetes locally_
  * Install [Google Cloud SDK](https://cloud.google.com/sdk/)
    (If you want to deploy to google)


## Developing locally

Run `make setup-dev` in the base repo folder.  This will start a kubernetes instance locally using minikube, and configure it to run our app.

It will ask you to set a database username and password for Postgres.

Once this is running, use `minikube ip` to see what IP address it's running on.

The __app__ directory is mounted inside the kubernetes pod, so you can modify the python code and changes will automatically be reloaded in the local kubernetes instance.



## Some Useful Commands

Command                | Description
------------------------------------------
`minikube ip`          | See the Ip that minikube is running on locally.
`minikube stop`        | Stop the minikube (does not delete app)
`minikube dashboard`   | Get the address of the Kubernetes Dashboard for local.
`make stream-logs-dev` | Stream the app(specifically Pyhton/flask) logs to the terminal

## Browsing the Database

[PgAdmin](https://www.pgadmin.org/) can be used as a database explorer.  When running locally, the database is accessible through the minikube ip address on port 5432.


### TODO
  * Inspect database
  * Run database migration

## Deploying To Google Container Engine
