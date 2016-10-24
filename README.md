# npm-yarn-benchmark

[![Build Status](https://travis-ci.org/artberri/npm-yarn-benchmark.svg?branch=master)](https://travis-ci.org/artberri/npm-yarn-benchmark)
[![Build Status](https://snap-ci.com/artberri/npm-yarn-benchmark/branch/master/build_image)](https://snap-ci.com/artberri/npm-yarn-benchmark/branch/master)
[![Build Status](https://semaphoreci.com/api/v1/artberri/npm-yarn-benchmark/branches/master/badge.svg)](https://semaphoreci.com/artberri/npm-yarn-benchmark)
[![CircleCI](https://circleci.com/gh/artberri/npm-yarn-benchmark.svg?style=shield)](https://circleci.com/gh/artberri/npm-yarn-benchmark)
[![wercker status](https://app.wercker.com/status/f010b6017b2d43bdad5baa95cf90f840/s/master "wercker status")](https://app.wercker.com/project/byKey/f010b6017b2d43bdad5baa95cf90f840)

Bash script for comparing NPM and Yarn performance.

Any improvement is welcome!

Create a pull request with your changes or let me know how to improve it by creating an issue.

## Run the benchmarking

```
./benchmark.sh
```

By default it will run twice each installation, use `-n` to change the number of iterations.

```
./benchmark.sh -n 10
```

The test is run by installing angular2, ember and reach N times. Each series is run twice, the
first time cleaning the cache in every run and the second one using the cache.
