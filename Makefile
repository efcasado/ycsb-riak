.PHONY: all build up down load run cluster-info show-riak-config

DOCKER_NETWORK=ycsb-riak_default

all: | build up cluster-info load run

build:
	docker build . -t ycsb

up:
	docker-compose up -d
	docker-compose exec --index=1 -- riak riak-admin wait-for-service riak_kv
	-docker-compose exec --index=1 -- riak riak-admin bucket-type create ycsb '{"props":{"allow_mult":"false"}}'
	-docker-compose exec --index=1 -- riak riak-admin bucket-type activate ycsb
	docker-compose exec --index=2 -- riak riak-admin wait-for-service riak_kv
	-docker-compose exec --index=2 -- riak riak-admin cluster join riak@$$(docker-compose ps -q | head -n1 | xargs docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
	docker-compose exec --index=3 -- riak riak-admin wait-for-service riak_kv
	-docker-compose exec --index=3 -- riak riak-admin cluster join riak@$$(docker-compose ps -q | head -n1 | xargs docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
	docker-compose exec --index=1 -- riak riak-admin cluster plan
	docker-compose exec --index=1 -- riak riak-admin cluster commit

down:
	-docker-compose down

load:
	docker run --rm -it --network=$(DOCKER_NETWORK) ycsb load riak -P workloads/workloada -p riak.hosts=ycsb-riak-riak-1,ycsb-riak-riak-2,ycsb-riak-riak-3 -p riak.debug=true

run:
	docker run --rm -it --network=$(DOCKER_NETWORK) ycsb run riak -P workloads/workloada -p riak.hosts=ycsb-riak-riak-1,ycsb-riak-riak-2,ycsb-riak-riak-3 -p riak.debug=true

cluster-info:
	docker-compose exec --index=1 -- riak riak-admin cluster status
	docker-compose exec --index=1 -- riak riak-admin cluster partitions
	docker-compose exec --index=2 -- riak riak-admin cluster partitions
	docker-compose exec --index=3 -- riak riak-admin cluster partitions

show-riak-config:
	docker-compose exec --index=1 -- riak riak config effective
