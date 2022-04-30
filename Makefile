.PHONY: build run up down

build:
	docker build . -t ycsb

run:
	echo "TODO: run!"

up:
	docker-compose up -d

down:
	-docker-compose down
