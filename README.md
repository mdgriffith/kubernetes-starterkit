# Kubernetes StarterKit
A basic Kubernetes setup for local development and deployment to google cloud.  

It installs the following:
  * A basic Python Flask app
  * Nginx
  * A Postgres Database

## Prerequisites

  * Clone this repo to a local dir.
  * Install [Google Cloud SDK](https://cloud.google.com/sdk/) _(If you want to deploy to google container engine)_
  * Install [kubectl](http://kubernetes.io/docs/user-guide/prereqs/) _(A command line utility for managing a kubernetes cluster)_
  * Install [minikube](https://github.com/kubernetes/minikube) _(for running kubernetes locally)_
  * Install Python 2.7, Virutalenv, and PIP


## Developing locally

To initially set everything up, run

`source activate.sh`

This will create a python virtualenv (which allows for the following `install` and `deploy` commands to work) and start a local kubernetes instance using minikube.

Run `install dev`.  This will build and deploy our app on the minikube.

It will ask you to set a database username and password for Postgres.

Once this is running, use `minikube ip` to see what IP address it's running on.

The __app/api__ directory is mounted inside the Kubernetes pod, so you can modify the python code and changes will automatically be reloaded in the local Kubernetes instance.

Same with the __app/nginx/serve__ drectory.  Adding files to that folder will serve them through the `static/` folder.

## Shutting down for the day

When you want to stop developing you can run

  * `deactivate`, which will turn off the python environment, which is what allows our `install` and `deploy` commands to work.  
  * `minikube stop` to stop the local minikube virtual machine.

Then, when you return to work on this project:

  * `source activate.sh` - Turn on minikube and activate our python environment.




## Some Useful Commands

Command                | Description
-----------------------|------------------
`minikube ip`          | See the Ip that minikube is running on locally.
`minikube stop`        | Stop the minikube (does not delete app)
`minikube start`       | Start the minikube
`minikube delete`      | Delete local kubernetes instance
`minikube dashboard`   | Get the address of the Kubernetes Dashboard for local.
`source activate.sh`   | Setup python so that the below commands can work
`deploy dev`           | Deploy a dev environment. 
`logs dev`             | Stream the app(specifically Python/flask) logs to the terminal
`deploy prod`          | Deploy to google container engine.

In the above commands, when `dev` or `prod` is mentioned, those correspond to config files in `/kube/deployments/`.


## Browsing the Database

[PgAdmin](https://www.pgadmin.org/) can be used as a database explorer.  

When running locally, the local database is accessible with the following information_schema:
 * _Host_ - 192.168.99.100 (or whatever the command `minikube ip` returns)
 * _Port_ - 32000
 * _Service_ - __blank__
 * _Username_ - Whatever username you specified when setting up.
 * _Password_ - Whatever password you specified when setting up.


## Deploying To Google Container Engine
Check out the DEPLOY-GOOGLE.md file for instructions.
