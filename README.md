# Yahoo! Cloud Serving Benchmark (YCSB) for Riak

Authored by Yahoo! Research in [2010](https://people.cs.pitt.edu/~chang/231/y13/papers/benchmarkcloud.pdf),
[YCSB](https://github.com/brianfrankcooper/YCSB) is an extensible workload
generator for benchmarking key-value stores.

A typical `YCSB` run consists of loading key-value pairs into the target data
store, run a specific workload against the target data store, and reporting
statistics.

Whilst `YCSB` allows you to define custom workloads, it also ships with a series
of [predefined workloads](https://github.com/brianfrankcooper/YCSB/tree/master/workloads),
which are ready to be used with little to no configuration.
The [official wiki](https://github.com/brianfrankcooper/YCSB/wiki/Core-Workloads)
of the project provides some information about these.

This repository aims at simplifying and illustrating how `YCSB` can be used
to benchmark different [Riak](https://riak.com/) configurations.

For more information about how YCSB can be configured to interact with Riak,
please, check `YCSB`'s Riak client
[documentation](https://github.com/brianfrankcooper/YCSB/tree/master/riak).


## Requirements

- [GNU Make](https://www.gnu.org/software/make/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)


## Get Started

Running `make all` (or just `make`) will package `YCSB` as a (local) Docker
image, will spin up a 3-node Riak cluster and will run a `YCSB` test-run
against the latter.
