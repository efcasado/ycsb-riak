# Yahoo! Cloud Serving Benchmark (YCSB) for Riak

Authored by Yahoo! Research in [2010](https://people.cs.pitt.edu/~chang/231/
y13/papers/benchmarkcloud.pdf), [YCSB](https://github.com/brianfrankcooper/
YCSB) is an extensible workload generator for benchmarking key-value stores.

A typical `YCSB` run consists of loading key-value pairs into the target data
store, run a specific workload against the target data store, and reporting
statistics.

Whilst `YCSB` allows you to define custom workloads, it also ships with a series
of [predefined workloads](https://github.com/brianfrankcooper/YCSB/tree/master/
workloads), which are ready to be used with little to no configuration. The
[official wiki](https://github.com/brianfrankcooper/YCSB/wiki/Core-Workloads)
of the project provides some information about these.

This repository aims at simplifying and illustrating how `YCSB` can be used
to benchmark different [Riak](https://riak.com/) configurations.

For more information about how YCSB can be configured to interact with Riak,
please, check `YCSB`'s Riak client [documentation](https://github.com/
brianfrankcooper/YCSB/tree/master/riak).


## Get Started

```
make build
```

```
docker run --rm -it ycsb load basic -P workloads/workloada
docker run --rm -it ycsb run basic -P workloads/workloada
```

```
make up
```

```
docker run --rm -it ycsb load riak -P workloads/workloada -p riak.hosts=host.docker.internal
docker run --rm -it ycsb run riak -P workloads/workloada -p riak.hosts=host.docker.internal
```
