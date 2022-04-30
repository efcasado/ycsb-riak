.PHONY: build run up down

build:
	docker build . -t ycsb

run:
	echo "TODO: run!"

up:
	docker-compose up -d
	docker-compose exec riak riak-admin wait-for-service riak_kv
	-docker-compose exec riak riak-admin bucket-type create ycsb '{"props":{"allow_mult":"false"}}'
	-docker-compose exec riak riak-admin bucket-type activate ycsb

down:
	-docker-compose down
