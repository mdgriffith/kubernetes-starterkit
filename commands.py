import string
import random
import os
import os.path

import click
import subprocess
import getpass
import yaml
import voluptuous
from voluptuous import Required, Optional
import time


config_schema = voluptuous.Schema({
    Required('deployment'): {
        Optional('require-clean-git'): bool,
        Optional('gcloud'): { Optional('persistent-disk'): { Required('name'): str,
                                                             Required('size'): str
                                                            }, 
                              Optional('cluster'): { Required('name'): str,
                                                     Required('machine-type'): str,
                                                     Required('zone'): str,
                                                     Required('num-nodes'): str
                                                    },
                              Optional('push-images', default=False): bool 
                             },
        Required('docker'): { Required('cmd'): str, 
                              Optional('repo', default=None): str
                             },
        Required('kubernetes'): { Required('context'):str
                                , Required('configs'):[str]
                                , Optional('config-templates', default=None):[{Required('template'):str, Required('target'):str}]
                                },
        Required('images'): [ { Required('name'):str
                              , Required('location'):str
                              , Required('tags'):str
                              , Optional('dockerfile', default=None):str
                              }
                            ]
   }
 })



class StarterkitConfig(click.ParamType):

    name = 'starterkit config'

    def __init__(self, base_dir):
        self.base_dir = base_dir

    def convert(self, value, param, ctx):
        try:
            with open(os.path.join(self.base_dir, value + ".yaml")) as CONFIG:
                config = yaml.load(CONFIG.read())
                config_schema(config)
                if config["deployment"]["kubernetes"]["context"] == "gcr.io/GOOGLE_PROJECT":
                    raise Exception('Config', 'Please set the GOOGLE_PROJECT repo in ' + os.path.join(self.base_dir, value + ".yaml"))
                if config["deployment"]["docker"].get("repo", None) == "GOOGLE_CONTEXT":
                    raise Exception('Config', 'Please set the GOOGLE_CONTEXT to deploy to in ' + os.path.join(self.base_dir, value + ".yaml"))
                config["deployment"]['require-clean-git'] = config["deployment"].get('require-clean-git', False)
                return config
        except IOError:
            self.fail('There is no {cfg}.yaml config in {base}'.format(
                cfg=value, base=self.base_dir), param, ctx)


#---------------------------
# gcloud operations
#---------------------------

def create_cluster_if_doesnt_exist(cluster):
    running = subprocess.call("gcloud container clusters describe {name} --zone {zone}".format(name=cluster["name"], zone=cluster["zone"]), shell=True, stdout=open(os.devnull, 'wb'), stderr=open(os.devnull, 'wb'))
    if running == 0:
        return True
    else:
        subprocess.call("gcloud container clusters create {name} --machine-type {machine_type} --zone {zone} --num-nodes {num_nodes}".format(**cluster), shell=True)


def create_disk_if_doesnt_exist(disk):
    running = subprocess.call("gcloud compute disks describe {name} --zone {zone}".format(name=disk["name"], zone=disk["zone"]), shell=True, stdout=open(os.devnull, 'wb'), stderr=open(os.devnull, 'wb'))
    if running == 0:
        return True
    else:
        subprocess.call("gcloud compute disks create --size={size} --zone={zone} {name}".format(**disk), shell=True)


# ---------------------------
# Build Images
# ---------------------------
def get_image_names(config):
    if repo is None:
        repo = "library"
    full_image_name = "{repo}/{image_name}:{version}".format(
        repo=repo, image_name=name, version=tags)
    return {name: full_image_name}

def build_image(name, location, tags, repo=None, dockerfile=None):
    if dockerfile is None:
        dockerfile = "Dockerfile"
    if repo is None:
        repo = "library"
    full_image_name = "{repo}/{image_name}:{version}".format(
        repo=repo, image_name=name, version=tags)
    full_dockerfile = os.path.join(location, dockerfile)
    subprocess.call("docker build -t {full_image_name} -f {dockerfile} {location}".format(
        full_image_name=full_image_name, location=location, dockerfile=full_dockerfile), shell=True)
    return {name: full_image_name}

def build_all_images(config):
    image_names = {}
    for image in config["deployment"]["images"]:
        if not "repo" in image:
            image["repo"] = config["deployment"][
                "docker"].get("repo", None)
        image_names.update(build_image(**image))
    return image_names

def push_images(image_names):
    print "Pushing images to gcloud"
    for name, full_name in image_names.items():
        subprocess.call(
            "gcloud docker push {image}".format(image=full_name), shell=True)



def format_kube_template(template, target, **substitutions):
    with open(template) as KUBE:
        with open(target, "w") as KUBETARGET:
            template = KUBE.read()
            KUBETARGET.write(template.format(**substitutions))
# ---------------------------
# Handle Kubernetes Configuration
# ---------------------------


def apply_kube_config(kube):
    subprocess.call("kubectl apply -f {kube};".format(kube=kube), shell=True)


def create_session_secret():
    if not secret_exists("session-secret"):
        secret = "".join(
            [random.choice(string.ascii_letters + string.digits) for n in xrange(64)])
        subprocess.call(
            "kubectl create secret generic session-secret --from-literal=session-secret={SECRET}".format(SECRET=secret), shell=True)


def create_database_credentials():
    if not secret_exists("postgres-credentials"):
        username = getpass.getpass("Postgres username?")
        password = getpass.getpass("Postgres password?")
        subprocess.call("kubectl create secret generic postgres-credentials --from-literal=username={username} --from-literal=password={password}".format(
            username=username, password=password), shell=True)


def create_empty_certificate_secret():
    if not secret_exists("letsencrypt-certificates"):
        subprocess.call(
            "kubectl create secret generic letsencrypt-certificates --from-literal=status=empty", shell=True)


def secret_exists(secret_name):
    running = subprocess.call("kubectl get secrets {secret_name}".format(secret_name=secret_name), shell=True, stdout=open(os.devnull, 'wb'), stderr=open(os.devnull, 'wb'))
    if running == 0:
        return True
    else:
        return False


def schedule_cert_renewal():
    pass


# ---------------------------
# Utils
# ---------------------------
def is_git_clean():
    return subprocess.call("git diff-index --quiet HEAD --") == 0


def get_previous_version():
    return subprocess.call("git describe --abbrev=0 --tags")


def increment_version(version, version_type):
    versions = version.split(".")
    major = int(versions[0])
    minor = int(versions[1])
    patch = int(versions[2])

    if version == "major":
        major = major + 1
    elif version == "minor":
        minor = minor + 1
    elif version == "patch":
        patch = patch + 1

    return str(major) + "." + str(minor) + "." + str(patch)


def git_tag(tag, message):
    subprocess.call(
        'git tag -a {tag} -m "{message}"'.format(tag=tag, message=message))
    subprocess.call('git push --tags')


def set_kubernetes_context(context):
    subprocess.call(
        "kubectl config use-context {context}".format(context=context), shell=True)


def set_docker(cmd):
    running = subprocess.check_output(cmd, shell=True)
    for line in running.splitlines():
        if line.startswith('export'):
            (key, _, value) = line.lstrip('export ').partition("=")
            os.environ[key] = value.strip('"')


def get(config, keys, default):
    """ Get a nested value if present
    """
    current = config
    for key in keys:
        if key in current:
            current = current[key]
        else:
            return default
    return current


# ------------------
# Commands
# ------------------


@click.command()
@click.argument("config", type=StarterkitConfig(r'kube/deployments/'))
def parse(config):
    print "Deployment file looks good!"


@click.command()
@click.argument("config", type=StarterkitConfig(r'kube/deployments/'))
def deploy(config):
    """Deploy"""

    if get(config, ['deployment','require-clean-git'], False) and not is_git_clean():
        print "There are uncommitted changes.  Commit them and run deploy again."
        exit(1)
    # new_version = increment(get_previous_version(), version_type)
    # git_tag(new_version, new_version + " release")
    set_kubernetes_context(config["deployment"]["kubernetes"]["context"])
    set_docker(config["deployment"]["docker"]["cmd"])

    # # Build all images listed in config
    # # We grab the final image names + image version
    # # Sometimes the version is set dynamically within `build`
    image_names = build_all_images(config)
   

    if get(config, ["deployment","gcloud", "push-images"], False):
        push_images(image_names)

    # Take any templates and replace the following
    #  * Image names are expanded
    #  * Current working directory (for hostpath on dev volumes)
    for template in config["deployment"]["kubernetes"]["config-templates"]:
        format_kube_template(template["template"], template[
                             "target"], PROJECT_ROOT=os.getcwd(), **image_names)

    # These only create the secrets if necessary
    create_session_secret()
    create_database_credentials()
    create_empty_certificate_secret()


    # Apply Kubernetes Files
    for kube in config["deployment"]["kubernetes"]["configs"]:
        apply_kube_config(kube)
        time.sleep(30)

@click.command()
@click.argument("config", type=StarterkitConfig(r'kube/deployments/'))
def apply(config):
    set_kubernetes_context(config["deployment"]["kubernetes"]["context"])
    set_docker(config["deployment"]["docker"]["cmd"])
    # Apply Kubernetes Files
    for kube in config["deployment"]["kubernetes"]["configs"]:
        apply_kube_config(kube)

@click.command()
@click.argument("config", type=StarterkitConfig(r'kube/deployments/'))
def build(config):
    set_kubernetes_context(config["deployment"]["kubernetes"]["context"])
    set_docker(config["deployment"]["docker"]["cmd"])
    build_all_images(config)

@click.command()
@click.argument("config", type=StarterkitConfig(r'kube/deployments/'))
def push(config):
    image_names = get_image_names(config)
    if get(config, ["deployment","gcloud", "push-images"], False):
        push_images(image_names)


@click.command()
@click.argument("config", type=StarterkitConfig(r'kube/deployments/'))
def logs(config):
    print ""
    command = "kubectl logs POD --container flask-api --follow"


# @click.command()
# @click.argument("config", type=StarterkitConfig(r'kube/deployments/'))
# def request_certs():
#     # Request certs
#     subprocess.call("kubectl exec ")
#     # Get status of Certs
#     subprocess.call("kubectl")
#     # If
#     pass
