# npm-yarn-benchmark

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
