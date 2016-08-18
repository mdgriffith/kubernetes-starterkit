import click
import subprocess
import os
import os.path
import getpass
import yaml



class StarterkitConfig(click.ParamType):

    name = 'starterkit config'

    def __init__(self, base_dir):
        self.base_dir = base_dir

    def convert(self, value, param, ctx):
        try:
            with open(os.path.join(self.base_dir, value + ".yaml")) as CONFIG:
                config = yaml.load(CONFIG.read())
                return config
        except IOError:
            self.fail('There is no {cfg}.yaml config in {base}'.format(cfg=value, base=self.base_dir), param, ctx)


# ---------------------------
# Build Images
# ---------------------------
def build(image_name, location, tags, repo=None, dockerfile=None):
    if dockerfile is None:
        dockerfile = "Dockerfile"
    if repo is None:
        repo = "library"
    full_image_name = "{repo}/{image_name}:{version}".format(repo=repo, image_name=image_name, version=tags)
    subprocess.call("docker build -t {full_image_name} -f {dockerfile} {location}".format(full_image_name=full_image_name, location=location, dockerfile=dockerfile))
    return { image_name : full_image_name }

def format_kube_template(template, target, **substitutions):
    with open(template) as KUBE:
        with open(target, "w") as KUBETARGET:
            template = KUBE.read()
            KUBETARGET.write(template.format(**substitutions))
# ---------------------------
# Handle Kubernetes Configuration
# ---------------------------

def apply_kube_config(kube):
    subprocess.call("kubectl apply -f {kube};")

def create_session_secret():
    secret = os.urandom(64)
    subprocess.call("kubectl create secret generic session-secret --from-literal=session-secret={SECRET}".format(SECRET=secret))

def create_database_credentials():
    username = getpass("Postgres username?")
    password = getpass("Postgres password?")
    subprocess.call("kubectl create secret generic postgres-credentials --from-literal=username={username} --from-literal=password={password}".format(username=username, password=password))

def request_certs():
    pass

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
    subprocess.call('git tag -a {tag} -m "{message}"'.format(tag=tag, message=message))
    subprocess.call('git push --tags')



# ------------------
# Commands
# ------------------

@click.command()
def test():
    """Example script."""
    click.echo('TEST')



@click.command()
@click.argument("config", type=StarterkitConfig(r'kube/deployments/'))
def install(config):
    """
    Set up an initial installation.  This reads a deployment.yaml file from kube/deployments

    This is distinct from `deploy` in that it is run once at the beginning

    """
    # Build all images listed in config
    # We grab the final image names + image version
    # Sometimes the version is set dynamically within `build`
    image_names = {}
    for image in config["deployment"]["images"]:
        if not "repo" in image:
            image["repo"] = config["deployment"]["docker-env"].get("repo", None)
        image_names.update(build(**image))

    # Take any templates and replace the following
    #  * Image names are expanded
    #  * Current working directory (for hostpath on dev volumes)
    for template in config["deployment"]["kuberetes-env"]["config-templates"]:
        format_kube_template(template.template, template.target, PROJECT_ROOT=os.getcwd(), **image_names)

    create_session_secret()
    create_database_credentials()
    # Apply Kubernetes Files
    for kube in config["deployment"]["kuberetes-env"]["configs"]:
        apply_kube_config(kube)


@click.command()
@click.argument("config", type=StarterkitConfig(r'kube/deployments/'))
@click.argument("version_type", type=click.Choice(['major', 'minor', 'patch']))
def deploy(config, version_type):
    """Deploy"""
    if not is_git_clean():
        print "There are uncommitted changes.  Commit them and run deploy again."
        exit(1)
    new_version = increment(get_previous_version(), version_type)
    git_tag(new_version, new_version + " release")
