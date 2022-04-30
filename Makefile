.PHONY: all build up down load run

all: | build up load run

build:
	docker build . -t ycsb

up:
	docker-compose up -d
	docker-compose exec riak riak-admin wait-for-service riak_kv
	-docker-compose exec riak riak-admin bucket-type create ycsb '{"props":{"allow_mult":"false"}}'
	-docker-compose exec riak riak-admin bucket-type activate ycsb

down:
	-docker-compose down

load:
	docker run --rm -it ycsb load riak -P workloads/workloada -p riak.hosts=host.docker.internal -p riak.debug=true

run:
	docker run --rm -it ycsb run riak -P workloads/workloada -p riak.hosts=host.docker.internal -p riak.debug=true
