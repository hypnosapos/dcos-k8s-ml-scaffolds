.DEFAULT_GOAL := help

DOCKER_GIT_SPARK   ?= branch-2.4
DOCKER_ORG         ?= hypnosapos
DOCKER_IMAGE       ?= dcos-k8s
DOCKER_TAG         ?= latest

GITHUB_TOKEN       ?= 1234567890

GCP_CREDENTIALS    ?= path/your-credentials-gcp.json

DCOS_PRIVATE_KEY   ?= path/your-private-ssh-key
DCOS_PUBLIC_KEY    ?= path/your-private-ssh-key.pub

UNAME := $(shell uname -s)
ifeq ($(UNAME),Linux)
OPEN := xdg-open
else
OPEN := open
endif

.PHONY: help
help: ## Show this help.
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean-all
clean-all: dcos-destroy docker-clean  ## Clean all

.PHONY: docker-clean
docker-clean: ## Delete docker container and image
	@docker rm -f $$(docker ps -a -f "ancestor=$(DOCKER_ORG)/$(DOCKER_IMAGE):$(DOCKER_TAG)" --format '{{.Names}}') > /dev/null 2>&1 || true
	@docker rmi -f $(DOCKER_ORG)/$(DOCKER_IMAGE):$(DOCKER_TAG) > /dev/null 2>&1 || true

.PHONY: docker-build
docker-build: ## Build the proxy docker image.
	@docker build -t $(DOCKER_ORG)/$(DOCKER_IMAGE):$(DOCKER_TAG) .

.PHONY: docker-push
docker-push: ## Publish docker image.
	@docker push $(DOCKER_ORG)/$(DOCKER_IMAGE):$(DOCKER_TAG)

.PHONY: docker-run
docker-run: ## Run a docker container to manage dcos.
	@docker run -d -it --name dcos-k8s \
	 -e GITHUB_TOKEN=$(GITHUB_TOKEN) \
	 -v $(GCP_CREDENTIALS):/dcos-kubernetes-quickstart/gcp.json \
	 -v $(DCOS_PRIVATE_KEY):/dcos-kubernetes-quickstart/dcos_gcp \
	 -v $(DCOS_PUBLIC_KEY):/dcos-kubernetes-quickstart/dcos_gcp.pub \
	 -v $(shell pwd)/resources/desired_cluster_profile.gcp:/dcos-kubernetes-quickstart/resources/desired_cluster_profile.gcp \
	 -v $(shell pwd)/resources/options.json.gcp:/dcos-kubernetes-quickstart/resources/options.json.gcp \
	 $(DOCKER_ORG)/$(DOCKER_IMAGE):$(DOCKER_TAG)

.PHONY: dcos
dcos: ## Setup dcos on GCP
	@docker exec -it dcos-k8s \
	   bash -c "./dcos.sh"

.PHONY: dcos-k8s
dcos-k8s: ## Deploy kubernetes service on dcos.
	@docker exec -it dcos-k8s \
	   sh -c "make install watch-kubernetes-cluster"

.PHONY: dcos-destroy
dcos-destroy: ## Destroy resources on GCP
	@docker exec -it dcos-k8s \
	   bash -c "make destroy"