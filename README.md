# Kubeflow over kubernetes service on DC/OS (flying on GCP)

This project is almost a fake, just collect command lines to run kubeflow on kubernetes service of DC/OS cluster in GCP (no checked for other cloud providers),
based on https://github.com/mesosphere/dcos-kubernetes-quickstart.

## HowTo

Clone the require project:

```sh
$ git clone https://github.com/mesosphere/dcos-kubernetes-quickstart
```

Read the docs (README.md) of the project and adjust values of configuration resources into the directory `resources`.

Keep these values on resource `desired_cluster_profile.gcp`:

```
gcp_ssh_pub_key_file = "/dcos-kubernetes-quickstart/dcos_gcp.pub"
gcp_credentials_key_file = "/dcos-kubernetes-quickstart/gcp.json"
```

After that, run the container adding these volumes to the container:

```sh
docker run -it \
   -e GITHUB_TOKEN=*********** \
   -v $(pwd)/dcos-kubernetes-quickstart/resources:/dcos-kubernetes-quickstart/resources \
   -v $(pwd)/your-credentials-gcp.json:/dcos-kubernetes-quickstart/gcp.json \
   -v $(pwd)/your-private-ssh-key:/dcos-kubernetes-quickstart/dcos_gcp \
   -v $(pwd)/your-public-ssh-key:/dcos-kubernetes-quickstart/dcos_gcp.pub \
   hypnosapos/dcos-k8s-kubeflow bash

# ./cmd.sh
```

While DC/OS is installing in the shell will appear an URL to get a valid token via OAuth, select one and copy/paste the value.

Type `make ui` (or command `dcos cluster list`) to get the public URL of the DCOS web console and `make kube-ui` for the kubernetes dashboard URL.

As result of the default command you should have a kubeflow installation over your kubernetes service on DCOS.

If you want to deploy some kubeflow examples:

```sh
./kubeflow_example.sh
./kubeflow_seldon.sh
```

## Removing

When you finish remind clean all resources, to do that type this command inside the docker container:

```sh
make destroy
```

or:

```sh
cd .deploy
terraform destroy  -lock=false -var-file desired_cluster_profile
```