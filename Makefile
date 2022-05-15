.PHONY: all build up down load run cluster-info show-riak-config
.PHONY: up-local up-remote down-local down-remote
.PHONY: load-local load-remote run-local run-remote
.PHONY: cluster-info-local cluster-info-remote show-riak-config-local show-riak-config-remote

SHELL = BASH_ENV=.rc /bin/bash --noprofile

USE_DOCKER ?= 1
DOCKER_NETWORK ?= ycsb-riak_default
DOCKER_YCSB_CPUS ?= 1
DOCKER_RIAK_CPUS ?= 1
RIAK_INSTANCES ?= 3
YCSB_RECORD_COUNT ?= 1000
YCSB_OPERATION_COUNT ?= 1000
YCSB_THREADS ?= 1
YCSB_TARGET ?= 100

ifeq ($(USE_DOCKER),1)
	TARGET_SUFFIX=-local
else
	TARGET_SUFFIX=-remote
endif

all: | build up cluster-info load run

build:
	docker build . -t ycsb

up: up$(TARGET_SUFFIX)
up-local:
	@DOCKER_RIAK_CPUS=$(DOCKER_RIAK_CPUS) RIAK_INSTANCES=$(RIAK_INSTANCES) docker-compose up -d
	@docker-compose exec --index=1 -- riak riak-admin wait-for-service riak_kv
	-@docker-compose exec --index=1 -- riak riak-admin bucket-type create ycsb '{"props":{"allow_mult":"false"}}'
	-@docker-compose exec --index=1 -- riak riak-admin bucket-type activate ycsb
	$(eval RIAK_INSTANCES := $(shell seq 1 1 $(RIAK_INSTANCES)))
	-@RIAK_INSTANCES=($(RIAK_INSTANCES));for RIAK_INSTANCE in $${RIAK_INSTANCES[@]:1}; do \
		echo "Configuring Riak #$$RIAK_INSTANCE" ;\
		docker-compose exec --index=$$RIAK_INSTANCE -- riak riak-admin wait-for-service riak_kv ;\
		docker-compose exec --index=$$RIAK_INSTANCE -- riak riak-admin cluster join riak@$$(docker-compose ps -q | head -n1 | xargs docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}') ;\
	done
	-@RIAK_INSTANCES=($(RIAK_INSTANCES)); RIAK_INSTANCES="$${RIAK_INSTANCES[@]:1}"; if [ $${#RIAK_INSTANCES[@]} -gt 1 ]; then \
		echo "Configuring cluster" ;\
		docker-compose exec --index=1 -- riak riak-admin cluster plan ;\
		docker-compose exec --index=1 -- riak riak-admin cluster commit ;\
	fi
up-remote:
	cd terraform; terraform init
	cd terraform; terraform apply -auto-approve
	sleep 30
	cd ansible; ansible-playbook -i scaleway/inventory.yml playbooks/install-and-configure-riak.yml
	cd ansible; ansible-playbook -i scaleway/inventory.yml playbooks/configure-riak-cluster.yml
	cd ansible; ansible-playbook -i scaleway/inventory.yml playbooks/install-and-configure-ycsb.yml

down: down$(TARGET_SUFFIX)
down-local:
	-docker-compose down
down-remote:
	cd terraform; terraform destroy -auto-approve

load: load$(TARGET_SUFFIX)
load-local:
	YCSB_RIAK_HOSTS=$$(docker ps --format "{{.Names}}" | grep ycsb-riak-riak | xargs | tr ' ' ','); docker run --cpus=$(DOCKER_YCSB_CPUS) --rm -it --network=$(DOCKER_NETWORK) ycsb load riak -P workloads/workloada -threads $(YCSB_THREADS) -target $(YCSB_TARGET) -p recordcount=$(YCSB_RECORD_COUNT) -p riak.hosts=$${YCSB_RIAK_HOSTS} -p riak.debug=true
load-remote:
	docker run --cpus=$(DOCKER_YCSB_CPUS) --rm -it --network=default ycsb load riak -P workloads/workloada -threads $(YCSB_THREADS) -target $(YCSB_TARGET) -p recordcount=$(YCSB_RECORD_COUNT) -p riak.hosts=$$(cd ansible; ansible-inventory --list -i scaleway/inventory.yml all | grep -v INFO | jq '._meta."hostvars" | .[] | .public_ipv4' | xargs | tr ' ' ',') -p riak.debug=true

run: run$(TARGET_SUFFIX)
run-local:
	YCSB_RIAK_HOSTS=$$(docker ps --format "{{.Names}}" | grep ycsb-riak-riak | xargs | tr ' ' ','); docker run --cpus=$(DOCKER_YCSB_CPUS) --rm -it --network=$(DOCKER_NETWORK) ycsb run riak -P workloads/workloada -threads $(YCSB_THREADS) -target $(YCSB_TARGET) -p recordcount=$(YCSB_RECORD_COUNT) -p operationcount=$(YCSB_OPERATION_COUNT) -p riak.hosts=$(YCSB_RIAK_HOSTS) -p riak.debug=true
run-remote:
	$(eval YCSB_RIAK_HOSTS=$(shell cd ansible; ansible-inventory --list -i scaleway/inventory.yml all | jq '._meta."hostvars" | .[] | .public_ipv4' | xargs | tr ' ' ','))
	docker run --cpus=$(DOCKER_YCSB_CPUS) --rm -it --network=default ycsb load riak -P workloads/workloada -threads $(YCSB_THREADS) -target $(YCSB_TARGET) -p recordcount=$(YCSB_RECORD_COUNT) -p operationcount=$(YCSB_OPERATION_COUNT) -p riak.hosts=$(YCSB_RIAK_HOSTS) -p riak.debug=true

cluster-info: cluster-info$(TARGET_SUFFIX)
cluster-info-local:
	$(eval RIAK_INSTANCES := $(shell seq 1 1 $(RIAK_INSTANCES)))
	docker-compose exec --index=1 -- riak riak-admin cluster status
	-@RIAK_INSTANCES=($(RIAK_INSTANCES));for RIAK_INSTANCE in $${RIAK_INSTANCES[@]}; do \
		echo "XXX=$$RIAK_INSTANCE" ;\
		docker-compose exec --index=$$RIAK_INSTANCE -- riak riak-admin cluster partitions ;\
	done
cluster-info-remote:
	cd ansible; ansible -i scaleway/inventory.yml riak1 -m shell -a "riak-admin cluster status"
	cd ansible; ansible -i scaleway/inventory.yml riak -m shell -a "riak-admin cluster partitions"


show-riak-config: show-riak-config$(TARGET_SUFFIX)
show-riak-config-local:
	docker-compose exec --index=1 -- riak riak config effective
show-riak-config-remote:
	cd ansible; ansible -m shell -a 'riak config effective' -i scaleway/inventory.yml riak1
