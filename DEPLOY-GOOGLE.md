# WARNING, this guide is untested yet.


# Deploying to Google Container engine
First, have a working local setup as covered by the README.

Once that is set up, you'll need an account for [Google Cloud Platform](https://cloud.google.com/).

Enable billing.  As well initialize Google Compute and Google Container engine for your project by visiting these sites:

  * https://console.cloud.google.com/compute
  * https://console.cloud.google.com/kubernetes

You'll also need the `gcloud` [command line tool](https://cloud.google.com/sdk/docs/).  [Here's an overview of the gcloud](https://cloud.google.com/sdk/gcloud/reference/)

# Setting up Google Credential
First, add your google credentials by running the following command.

`gcloud auth login YOUREMAIL@gmail.com`

This will take you to a browser screen to login.

# Set Default Google Project
You can skip this if you only have one project.
Otherwise use the following command to list projects:

`gcloud projects list`

This command to view what the current default project is

`gcloud config list`

And the following to set a new default project.

`gcloud config set project my-project-name`


# Create a New Cluster on Google Container Engine

This can be done through the web interface or through gcloud.

Using gcloud, create a new cluster using the following:

`gcloud container clusters create NAMEOFCLUSTER --machine-type n1-standard-1 --zone us-east1-c --num-nodes 1`

Where machine-types are [listed here](https://cloud.google.com/compute/docs/machine-types) and [regions are listed here](https://cloud.google.com/compute/docs/regions-zones/regions-zones).  The number of nodes, is how many machines you want in use.


# Point Kubectl at Your New Cluster

Open the following file:

`/kube/scripts/deployment-envs/set-google-env.sh`

You need to replace `my-google-project` with your  google project name.

And replace `context_to_deploy_to` to the google context for your cluster.  You can see your contexts by running `gcloud config view`.

# Finally, Deploy.

First, commit all changes to your git.  Part of the deployment process is to tag which commit is being deployed.

Then run:

`make deploy`
