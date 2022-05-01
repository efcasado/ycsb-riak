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

You can change the settings of your Riak cluster by adjusting the
[user.conf](https://github.com/efcasado/ycsb-riak/blob/main/etc/riak/user.conf)
file included in this repository. For more information about how to configure
a Riak cluster, please, check Riak's
[official documentation](https://docs.riak.com/riak/kv/latest/configuring/basic/index.html).

You may also be interested in adjusting the load-generation parameters of
`YCSB`. You can do this by setting the `YCSB_{THREADS, TARGET, RECORD_COUNT, OPERATION_COUNT}`
variables, which default to `1`, `100`, `1000` and `1000`, respectively.

```
YCSB_THREADS=4 YCSB_TARGET=500 YCSB_RECORD_COUNT=10000 YCSB_OPERATION_COUNT=10000 make load
YCSB_THREADS=4 YCSB_TARGET=500 YCSB_RECORD_COUNT=10000 YCSB_OPERATION_COUNT=10000 make run
```

The above example configures `YCSB` to use `4` threads to try to achieve a
throughput of `500` requests per second while loading `10_000` entries in the
database and executing `10_000` operations against the loaded data.
