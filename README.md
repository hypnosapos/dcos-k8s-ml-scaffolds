# Kubeflow over kubernetes service on DC/OS (flying on GCP)
[![Build status](https://circleci.com/gh/hypnosapos/dcos-k8s-ml-scaffolds/tree/master.svg?style=svg)](https://circleci.com/gh/hypnosapos/dcos-k8s-ml-scaffolds/tree/master)
[![Layers](https://images.microbadger.com/badges/image/hypnosapos/dcos-k8s-ml-scaffolds.svg)](https://microbadger.com/images/hypnosapos/dcos-k8s-ml-scaffolds)
[![Version](https://images.microbadger.com/badges/version/hypnosapos/dcos-k8s-ml-scaffolds.svg)](https://microbadger.com/images/hypnosapos/dcos-k8s-ml-scaffolds)


This project is almost a fake, just collect command lines to run kubeflow or seldon on kubernetes service of DC/OS cluster in GCP (no checked for other cloud providers),
based on https://github.com/mesosphere/dcos-kubernetes-quickstart.

## HowTo

Clone the required project:

```sh
$ git clone https://github.com/mesosphere/dcos-kubernetes-quickstart
```

Read the docs (README.md) of the project and adjust values of configuration resources into the directory `resources`.

Keep these values on resource `desired_cluster_profile.gcp`:

```
gcp_ssh_pub_key_file = "/dcos-kubernetes-quickstart/dcos_gcp.pub"
gcp_credentials_key_file = "/dcos-kubernetes-quickstart/gcp.json"
```

After that, run the container adding these volumes:

```sh
docker run -it --name dcos-k8s \
   -e GITHUB_TOKEN=*********** \
   -v path/your-credentials-gcp.json:/dcos-kubernetes-quickstart/gcp.json \
   -v path/your-private-ssh-key:/dcos-kubernetes-quickstart/dcos_gcp \
   -v path/your-public-ssh-key:/dcos-kubernetes-quickstart/dcos_gcp.pub \
   -v path/desired_cluster_profile.gcp:/dcos-kubernetes-quickstart/resources/desired_cluster_profile.gcp \
   hypnosapos/dcos-k8s-ml-scaffolds

# ./dcos-kubernetes.sh
```

While DC/OS is installing in the shell will appear an URL to get a valid token via OAuth, select one method and copy/paste the value.
As result of the script you should have a kubernetes service on DCOS ready for action.

Type `make ui` (or command `dcos cluster list`) to get the public URL of the DCOS web console and `make kube-ui` for the kubernetes dashboard URL.

If you want to deploy some ML tools like kubeflow or seldon and examples:

```sh
# Kubeflow
./kubeflow.sh
./kubeflow_example.sh
./kubeflow_example_client.sh

#./kubeflow_seldon.sh

# Seldon
./seldon.sh
./seldon_example.sh
```

Also we can try out an Eclipse Che installation:

```sh
./eclipse_che.sh
```

## Removing

When you finish remind clean all resources, to do that type this command inside the docker container:

```sh
make destroy
```

or:

```sh
cd .deploy
terraform destroy -lock=false -var-file desired_cluster_profile
```

And finally, remove the container and its image:

```sh
docker rm -f dcos-k8s
# docker rm $(docker ps -a -f "ancestor=hypnosapos/dcos-k8s-ml-scaffolds" --format '{{.Names}}')
docker rmi -f hypnosapos/dcos-k8s-ml-scaffolds
```
