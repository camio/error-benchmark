# error-benchmark

This repository contains the source code for a micro benchmark of both
std::expected and standard exceptions.

## Getting the code

Check out the code in the normal way. Once done, use the following command to
pull in necessary submodules.

```bsh
git submodule update --init
```

## Building

Use the enclosed `Makefile`. A system installation of [Google
benchmark](https://github.com/google/benchmark) is assumed to be available.

## Running

Run the `benchmark` executable. The output should look something like this:

```shell
2022-12-13T21:46:14-05:00
Running ./benchmark
Run on (24 X 2660.09 MHz CPU s)
CPU Caches:
  L1 Data 32 KiB (x12)
  L1 Instruction 32 KiB (x12)
  L2 Unified 256 KiB (x12)
  L3 Unified 12288 KiB (x2)
Load Average: 1.16, 1.17, 1.12
------------------------------------------------------------------------------------
Benchmark                          Time             CPU   Iterations UserCounters...
------------------------------------------------------------------------------------
BM_loop_exp_happy/1048576    2371992 ns      2369237 ns          296 items_per_second=442.58M/s
BM_loop_exc_happy/1048576    4538855 ns      4533829 ns          149 items_per_second=231.278M/s
BM_loop_exp_sad/1048576      8239998 ns      8231550 ns           85 items_per_second=127.385M/s
BM_loop_exc_sad/1048576      3779382 ns      3775412 ns          186 items_per_second=277.738M/s
BM_loop_exp_mix/1048576      8582081 ns      8573149 ns           82 items_per_second=122.309M/s
BM_loop_exc_mix/1048576   1415963661 ns   1414671127 ns            1 items_per_second=741.215k/s
```

## The benchmarks

Each of the benchmarks run one of the two implementations of a very simple
function that returns `42` if its argument is `true` and produces an
`std::errc::io_error` otherwise. The exception code is in
[conderror_exc.C](conderror_exc.C) and the `std::expected` code is in
[conderror_exp.C](conderror_exc.C).

The benchmarks themselves cah be found within [benchmark.C](benchmark.C). If it
has `exc` in its name, it is using the exception function and if it has `exp`
in its name, it is using the `std::expected` function.

The `happy` benchmarks are measuring the speed of calling the function when it
does not encounter failure. The `sad` benchmarks do the same, but for when
failure is always encountered. The `mix` benchmarks measure function calls when
there is an alternating error/no-error case.

## Scripts

There are several scripts in the [scripts directory](scripts) that can be used
to run the benchmark multiple times, collate the output into a more useful
form, and create graphs.

## MacOS Notes

Install dependencies

```bsh
brew install google-benchmark
brew install pkg-config
brew install gnuplot
brew install jq
```

To build using the stock clang compiler, build like this:

```bsh
make CXX="clang++ --std=c++20"
```
